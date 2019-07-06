resource "kubernetes_ingress" "keycloak" {
  metadata {
    name      = "keycloak-ingress"
    namespace = "${var.namespace}"

    labels = {
      app = "keycloak"
    }

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "certmanager.k8s.io/issuer" = "vault-issuer"
    }
  }

  spec {
    tls {
      hosts = ["keycloak.testlab.local"]

      secret_name = "${var.name}"
    }

    rule {
      host = "keycloak.testlab.local"
      http {
        path {
          backend {
            service_name = "keycloak"
            service_port = "8080"
          }
        }
      }
    }
  }
}
