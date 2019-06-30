resource "null_resource" "cert-manager" {
    provisioner "local-exec" "cert-manager" {
        command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
    }
}

resource "helm_release" "cert-manager" {
  depends_on = ["null_resource.cert-manager"]
  name       = "cert-manager"
  repository = "${data.helm_repository.jetstack.metadata.0.name}"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "0.8.1"
}

#resource "null_resource" "vault-license" {
#    provisioner "local-exec" "cert-manager" {
#        command = "|
#            vault login "${var.vault_token}"
#            echo "${var.vault_license}" | vault write sys/license text=-"
#    }
#}

resource "vault_pki_secret_backend" "pki" {
  path = "pki"
  max_lease_ttl_seconds= "315360000"
}

resource "vault_pki_secret_backend_root_cert" "pki" {
  depends_on = [ "vault_pki_secret_backend.pki" ]

  backend = "${vault_pki_secret_backend.pki.path}"
  type = "exported"
  format = "pem_bundle"
  private_key_format = "der"
  key_type = "rsa"
  key_bits = 2048
  common_name = "Testlab Root CA"
  ttl = "315360000"
}

resource "vault_pki_secret_backend" "pki_int" {
  path = "pki_int"
  max_lease_ttl_seconds = "157680000"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_int" {
  depends_on = [ "vault_pki_secret_backend.pki_int" ]

  backend = "${vault_pki_secret_backend.pki_int.path}"
  type ="exported"
  common_name = "testlab.local"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki" {
  depends_on = [ "vault_pki_secret_backend_intermediate_cert_request.pki_int" ]

  backend = "${vault_pki_secret_backend.pki.path}"

  csr = "${vault_pki_secret_backend_intermediate_cert_request.pki_int.csr}"
  common_name = "TestLab Intermediate CA"
  ttl = "157680000"
  format = "pem_bundle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_int" { 
  backend = "${vault_pki_secret_backend.pki_int.path}"

  certificate = "${vault_pki_secret_backend_root_sign_intermediate.pki.certificate}"
}

resource "vault_pki_secret_backend_role" "cert-manager" {
  backend = "${vault_pki_secret_backend.pki_int.path}"
  name    = "cert-manager"
  ttl = "20m"
  allow_any_name = "true"
  generate_lease = "true"
}

resource "vault_pki_secret_backend_config_urls" "config_urls_root" {
  backend              = "${vault_pki_secret_backend.pki.path}"
  issuing_certificates = ["http://192.168.1.18:8300/v1/pki/ca"]
  crl_distribution_points = ["http://192.168.1.18:8300/v1/pki/crl"]
}

resource "vault_pki_secret_backend_config_urls" "config_urls_int" {
  backend              = "${vault_pki_secret_backend.pki_int.path}"
  issuing_certificates = ["http://192.168.1.18:8300/v1/pki_int/ca"]
  crl_distribution_points = ["http://192.168.1.18:8300/v1/pki_int/crl"]
}

resource "vault_policy" "cert-manager" {
  name = "cert-manager"

  policy = <<EOT
path "pki_int/sign/cert-manager" {
  capabilities = ["read", "update", "list", "delete"]
}
path "pki_int/issue/cert-manager" {
  capabilities = ["read", "update", "list", "delete"]
}
EOT
}

resource "vault_token" "cert-manager" {

  policies = ["cert-manager"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}

resource "kubernetes_secret" "cert-manager" {
  metadata {
    name = "cert-manager-vault-token"
    namespace = "kube-system"
  }

  data {
    token = "${base64encode(vault_token.cert-manager.client_token)}"
  }
}

resource "null_resource" "vault-issuer" {
    provisioner "local-exec" "vault_issuer" {
        command = "kubectl apply -f ./files/vault-issuer.yaml"
    }
}





