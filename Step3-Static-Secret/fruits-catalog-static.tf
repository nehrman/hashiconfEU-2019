resource "kubernetes_deployment" "fruits-catalog" {
  depends_on = ["kubernetes_cluster_role_binding.vault-auth"]

  metadata {
    name      = "fruits-catalog"
    namespace = "${var.namespace}"

    labels = {
      app      = "fruits-catalog"
      group    = "com.github.lbroudoux.msa"
      provider = "fabric8"
      version  = "1.0.0-SNAPSHOT"
    }
  }

  spec {
    strategy = {
      type = "RollingUpdate"

      rolling_update = {
        max_surge       = 1
        max_unavailable = 1
      }
    }

    replicas = 1

    revision_history_limit = 2

    selector {
      match_labels = {
        app      = "fruits-catalog"
        group    = "com.github.lbroudoux.msa"
        provider = "fabric8"
      }
    }

    template {
      metadata {
        labels = {
          app      = "fruits-catalog"
          group    = "com.github.lbroudoux.msa"
          provider = "fabric8"
          version  = "1.0.0-SNAPSHOT"
        }
      }

      spec {
        init_container {
          name = "vault-init"

          image = "quay.io/lbroudoux/ubi8:latest"

          command = [
            "/bin/sh",
            "-c",
            "MINIKUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token);curl -k --request POST --data '{\"jwt\": \"'\"$MINIKUBE_TOKEN\"'\", \"role\": \"fruits-catalog\"}' http://192.168.94.141:8200/v1/auth/minikube/login | jq -j '.auth.client_token' > /etc/vault/token;X_VAULT_TOKEN=$(cat /etc/vault/token);curl -k --header \"X-Vault-Token: $X_VAULT_TOKEN\" http://192.168.94.141:8200/v1/kv/fruits-catalog-mongodb > /etc/app/creds.json;echo \"spring.data.mongodb.uri=mongodb://$(jq -j '.data.user' /etc/app/creds.json):$(jq -j '.data.password' /etc/app/creds.json)@mongodb/sampledb\" > /etc/app/application.properties;cp /etc/app/application.properties /deployments/config/application.properties",
          ]

          volume_mount {
            name       = "app-creds"
            mount_path = "/etc/app"
          }

          volume_mount {
            name       = "vault-token"
            mount_path = "/etc/vault"
          }

          volume_mount {
            name       = "app-config"
            mount_path = "/deployments/config"
          }
        }

        container {
          name = "spring-boot"

          env = [
            {
              name  = "KEYCLOAK_URL"
              value = "https://keycloak.testlab.local/auth"
            },
            {
              name = "KUBERNETES_NAMESPACE"

              value_from {
                field_ref {
                  field_path = "metadata.namespace"
                }
              }
            },
          ]

          image = "msa/fruits-catalog:latest"

          image_pull_policy = "IfNotPresent"

          liveness_probe {
            http_get {
              path   = "/actuator/health"
              port   = 8080
              scheme = "HTTP"
            }

            timeout_seconds       = 3
            initial_delay_seconds = 15
            failure_threshold     = 3
            period_seconds        = 10
            success_threshold     = 1
          }

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "prometheus"
            container_port = 9779
            protocol       = "TCP"
          }

          port {
            name           = "jolokia"
            container_port = 8778
            protocol       = "TCP"
          }

          readiness_probe {
            failure_threshold = 3

            http_get {
              path   = "/actuator/health"
              port   = 8080
              scheme = "HTTP"
            }

            timeout_seconds       = 3
            initial_delay_seconds = 15
            period_seconds        = 10
            success_threshold     = 1
          }

          resources {
            limits {
              cpu    = "1"
              memory = "256Mi"
            }

            requests {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "app-creds"
            mount_path = "/etc/app"
          }

          volume_mount {
            name       = "vault-token"
            mount_path = "/etc/vault"
          }

          volume_mount {
            name       = "app-config"
            mount_path = "/deployments/config"
          }

          security_context {
            privileged = "false"
          }

          termination_message_path = "/dev/termination-log"
        }

        dns_policy = "ClusterFirst"

        restart_policy = "Always"

        service_account_name = "vault-auth"

        automount_service_account_token = true 

        volume {
          name      = "app-creds"
          empty_dir = {}
        }

        volume {
          name      = "app-config"
          empty_dir = {}
        }

        volume {
          name      = "vault-token"
          empty_dir = {}
        }

        termination_grace_period_seconds = 30
      }
    }
  }
}
