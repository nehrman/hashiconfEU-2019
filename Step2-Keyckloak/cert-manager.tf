resource "kubernetes_secret" "cert-manager-keycloak" {
  metadata {
    name      = "cert-manager-vault-token"
    namespace = "${var.namespace}"
  }

  data {
    token = "${vault_token.keycloak.client_token}"
  }

  type = "opaque"

}

resource "local_file" "vault-issuer" {
  content  = "${data.template_file.vault-issuer.rendered}"
  filename = "${path.module}/files/vault-issuer.yaml"
}

resource "null_resource" "vault-issuer" {
  depends_on = ["local_file.vault-issuer"]

  provisioner "local-exec" "vault_issuer" {
    command = "kubectl apply -f ./files/vault-issuer.yaml"
  }
}

resource "local_file" "keycloak-certificate" {
  content  = "${data.template_file.keycloak-certificate.rendered}"
  filename = "${path.module}/files/keycloak-certificate.yaml"
}

resource "null_resource" "keycloak-certificate" {
  depends_on = ["local_file.keycloak-certificate"]

  provisioner "local-exec" "keycloak-certificate" {
    command = "kubectl apply -f ./files/keycloak-certificate.yaml"
  }
}
