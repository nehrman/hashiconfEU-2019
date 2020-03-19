resource "kubernetes_service" "mongodb-vault" {
  metadata {
    name      = "mongodb-vault"
    namespace = "${var.namespace}"
  }

  spec {
    selector {
      app              = "fruits-catalog"
      container        = "mongodb"
      deploymentconfig = "mongodb"
    }

    port {
      node_port   = "${var.mongodb_nodeport}"
      port        = 27017
      protocol    = "TCP"
      target_port = 27017
    }

    type = "NodePort"
  }
}
