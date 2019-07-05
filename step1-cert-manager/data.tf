data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

data "helm_repository" "fabric8" {
  name = "fabric8"
  url  = "https://fabric8.io/helm"
}

data "template_file" "vault-issuer" {
  template = "${file("${path.module}/templates/vault-issuer.tpl")}"

  vars {
    namespace     = "${var.namespace}"
    vault_address = "${var.vault_addr}"
  }
}

data "template_file" "fruits-certificate" {
  template = "${file("${path.module}/templates/fruits-certificate.tpl")}"

  vars {
    name       = "${var.name}"
    namespace  = "${var.namespace}"
    commonname = "${var.commonname}"
    secretname = "${var.secretname}"
    dns_names  = "${var.dns_names}"
  }
}
