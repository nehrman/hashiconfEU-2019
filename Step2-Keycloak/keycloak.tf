resource "random_string" "adminkc" {
  length  = 16
  special = false
}

resource "random_string" "adminpg" {
  length  = 16
  special = false
}

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "kubernetes_secret" "keycloak" {
  metadata {
    name      = "keycloak-admin"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  data {
    username         = "adminKC"
    password         = "${random_string.adminkc.result}"
    postgresUsername = "adminPG"
    postgresPassword = "${random_string.adminpg.result}"
  }

  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_service" "keycloak-pgsql" {
  metadata {
    name      = "keycloak-postgresql"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  spec {
    selector = {
      app              = "keycloak-postgresql"
      deploymentconfig = "keycloak-postgresql"
    }

    session_affinity = "None"

    port {
      name        = "keycloak-postgresql"
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  spec {
    selector = {
      app = "keycloak"
    }

    session_affinity = "None"

    port {
      name        = "keycloak"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "keycloak-pgsql" {
  metadata {
    name      = "keycloak-postgresql"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  spec {
    resources {
      requests = {
        storage = "1Gi"
      }
    }

    access_modes = ["ReadWriteOnce"]
  }
}

resource "kubernetes_config_map" "keycloak" {
  metadata {
    name = "keycloak-config"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app       = "keycloak"
      container = "keycloak"
    }
  }

  data = {
    "fruits-catalog-realm.json" = "${file("${path.module}/files/fruits-catalog-realm.json")}"
  }
}

resource "kubernetes_deployment" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  spec {
    strategy = {
      type = "Recreate"
    }

    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name = "keycloak-server"

          image = "jboss/keycloak:6.0.1"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "jolokia"
            container_port = 8778
            protocol       = "TCP"
          }

          liveness_probe {
            failure_threshold = 3

            http_get {
              path   = "/auth/realms/master"
              port   = 8080
              scheme = "HTTP"
            }

            timeout_seconds       = 3
            initial_delay_seconds = 60
          }

          readiness_probe {
            failure_threshold = 10

            http_get {
              path   = "/auth/realms/master"
              port   = 8080
              scheme = "HTTP"
            }

            timeout_seconds       = 3
            initial_delay_seconds = 60
          }

          env = [
            {
              name = "INTERNAL_POD_IP"

              value_from {
                field_ref {
                  field_path = "status.podIP"
                }
              }
            },
            {
              name  = "KEYCLOAK_IMPORT"
              value = "/opt/jboss/keycloak/standalone/configuration/realm/fruits-catalog-realm.json"
            },
            {
              name = "KEYCLOAK_USER"

              value_from {
                secret_key_ref {
                  key  = "username"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name = "KEYCLOAK_PASSWORD"

              value_from {
                secret_key_ref {
                  key  = "password"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name  = "OPERATING_MODE"
              value = "clustered"
            },
            {
              name  = "DB_VENDOR"
              value = "POSTGRES"
            },
            {
              name = "DB_USER"

              value_from {
                secret_key_ref {
                  key  = "postgresUsername"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name = "DB_PASSWORD"

              value_from {
                secret_key_ref {
                  key  = "postgresPassword"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name  = "DB_DATABASE"
              value = "root"
            },
            {
              name  = "DB_ADDR"
              value = "keycloak-postgresql"
            },
            {
              name  = "KUBERNETES_LABELS"
              value = "deploymentconfig=keycloak"
            },
            {
              name = "KUBERNETES_NAMESPACES"

              value_from {
                field_ref {
                  field_path = "metadata.namespace"
                }
              }
            },
            {
              name  = "PROXY_ADDRESS_FORWARDING"
              value = "true"
            },
          ]

          volume_mount {
            name       = "keycloak-config"
            mount_path = "/opt/jboss/keycloak/standalone/configuration/realm"
          }

          security_context {
            privileged = false
          }
        }

        volume {
          name = "keycloak-config"

          config_map = {
            name = "${kubernetes_config_map.keycloak.metadata.0.name}"
          }
        }

        restart_policy = "Always"

        dns_policy = "ClusterFirst"
      }
    }
  }
}

resource "kubernetes_deployment" "keycloak-pgsql" {
  metadata {
    name      = "keycloak-postgresql"
    namespace = "${var.keycloak_namespace}"

    labels = {
      app = "keycloak"
    }
  }

  spec {
    strategy = {
      type = "Recreate"
    }

    replicas = 1

    selector {
      match_labels = {
        app              = "keycloak-postgresql"
        deploymentconfig = "keycloak-postgresql"
      }
    }

    template {
      metadata {
        labels = {
          app              = "keycloak-postgresql"
          deploymentconfig = "keycloak-postgresql"
        }
      }

      spec {
        termination_grace_period_seconds = 60

        container {
          name = "keycloak-postgresql"

          image = "centos/postgresql-95-centos7:latest"

          port {
            container_port = 5432
            protocol       = "TCP"
          }

          readiness_probe {
            timeout_seconds       = 1
            initial_delay_seconds = 5

            exec {
              command = [
                "/bin/sh",
                "-i",
                "-c",
                "psql 127.0.0.1 -U $POSTGRESQL_USER -q -d $POSTGRESQL_DATABASE -c 'SELECT 1'",
              ]
            }
          }

          liveness_probe {
            tcp_socket {
              port = 5432
            }

            timeout_seconds       = 1
            initial_delay_seconds = 30
          }

          env = [
            {
              name = "POSTGRESQL_USER"

              value_from {
                secret_key_ref {
                  key  = "postgresUsername"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name = "POSTGRESQL_PASSWORD"

              value_from {
                secret_key_ref {
                  key  = "postgresPassword"
                  name = "${kubernetes_secret.keycloak.metadata.0.name}"
                }
              }
            },
            {
              name  = "POSTGRESQL_DATABASE"
              value = "root"
            },
            {
              name  = "POSTGRESQL_MAX_CONNECTIONS"
              value = 100
            },
            {
              name  = "POSTGRESQL_SHARED_BUFFERS"
              value = "12MB"
            },
          ]

          volume_mount {
            name       = "keycloak-postgresql-data"
            mount_path = "/var/lib/pgsql/data"
          }
        }

        volume {
          name = "keycloak-postgresql-data"

          persistent_volume_claim = {
            claim_name = "keycloak-postgresql"
          }
        }
      }
    }
  }
}
