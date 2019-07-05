resource "kubernetes_ingress" "fruits-catalog" {
  metadata {
    name      = "fruits-catalog-ingress"
    namespace = "${var.namespace}"

    labels = {
      app = "fruits-catalog"
    }

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "certmanager.k8s.io/issuer" = "vault-issuer"
    }
  }

  spec {
    tls {
      hosts = ["fruits.testlab.local"]

      secret_name = "${var.name}"
    }

    rule {
      host = "fruits.testlab.local"
      http {
        path {
          backend {
            service_name = "fruits-catalog"
            service_port = "8080"
          }
        }
      }
    }
  }
}
