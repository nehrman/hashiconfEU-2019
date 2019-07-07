data "template_file" "minikube_auth" {
  template = "${file("${path.module}/templates/minikube_auth.tpl")}"

  vars {
    service_account     = "${kubernetes_service_account.vault-auth.metadata.0.name}"
    k8s_backend_path    = "minikube"
  }
}

