resource "kubernetes_namespace" "fruits-catalog" {
  metadata {
    name = "${var.namespace}"
  }
}

resource "kubernetes_namespace" "fabric8" {
  metadata {
    name = "fabric8"
  }
}

resource "helm_release" "fabric8" {
  name       = "fabric8-platform"
  repository = "${data.helm_repository.fabric8.metadata.0.name}"
  chart      = "fabric8-platform"
  namespace  = "fabric8"
}
