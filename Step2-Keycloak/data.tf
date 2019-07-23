data "template_file" "vault-issuer" {
  template = "${file("${path.module}/templates/vault-issuer.tpl")}"

  vars {
    namespace     = "${var.namespace}"
    vault_address = "${var.vault_addr}"
  }
}

data "template_file" "keycloak-certificate" {
  template = "${file("${path.module}/templates/keycloak-certificate.tpl")}"

  vars {
    name       = "${var.name}"
    namespace  = "${var.namespace}"
    commonname = "${var.commonname}"
    secretname = "${var.secretname}"
    dns_names  = "${var.dns_names}"
  }
}
