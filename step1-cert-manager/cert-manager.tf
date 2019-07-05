resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
    labels {
      "certmanager.k8s.io/disable-validation" = "true"
      name = "cert-manager"
    }
  }
}

resource "null_resource" "cert-manager-crds" {
  depends_on = ["kubernetes_namespace.cert-manager"]

  provisioner "local-exec" "cert-manager" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = ["null_resource.cert-manager-crds"]
  name       = "cert-manager"
  repository = "${data.helm_repository.jetstack.metadata.0.name}"
  chart      = "cert-manager"
  namespace  = "${kubernetes_namespace.cert-manager.metadata.0.name}"
  version    = "0.8.1"
}

resource "kubernetes_secret" "cert-manager" {
  metadata {
    name      = "cert-manager-vault-token"
    namespace = "cert-manager"
  }

  data {
    token = "cm9vdAo="
  }
}

resource "kubernetes_secret" "cert-manager-test" {
  metadata {
    name      = "cert-manager-vault-token"
    namespace = "${var.namespace}"
  }

  data {
    token = "cm9vdAo="
  }
}

resource "local_file" "vault-issuer" {
  content  = "${data.template_file.vault-issuer.rendered}"
  filename = "${path.module}/files/vault-issuer.yaml"
}

resource "null_resource" "vault-issuer" {
  depends_on = ["helm_release.cert-manager", "local_file.vault-issuer"]

  provisioner "local-exec" "vault_issuer" {
    command = "kubectl apply -f ./files/vault-issuer.yaml"
  }
}

resource "local_file" "fruits-certificate" {
  content  = "${data.template_file.fruits-certificate.rendered}"
  filename = "${path.module}/files/fruits-certificate.yaml"
}

resource "null_resource" "fruits-certificate" {
  depends_on = ["helm_release.cert-manager", "local_file.fruits-certificate"]

  provisioner "local-exec" "fruits-certificate" {
    command = "kubectl apply -f ./files/fruits-certificate.yaml"
  }
}
