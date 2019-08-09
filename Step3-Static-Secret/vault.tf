resource "vault_mount" "kv_store" {
  path = "kv"
  type = "kv"

  options = {
    version = 1
  }
}

resource "kubernetes_service_account" "vault-auth" {
  metadata {
    name      = "vault-auth"
    namespace = "${var.namespace}"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "vault-auth" {
  metadata {
    name = "role-tokenreview-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.vault-auth.metadata.0.name}"
    namespace = "${var.namespace}"
  }
}

resource "vault_auth_backend" "minikube" {
  type = "kubernetes"
  path = "minikube"
}

resource "local_file" "minikube_auth" {
  content  = "${data.template_file.minikube_auth.rendered}"
  filename = "${path.module}/files/minikube_auth.sh"
}

resource "null_resource" "minikube_auth_backend" {
  depends_on = ["local_file.minikube_auth", "vault_auth_backend.minikube", "kubernetes_service_account.vault-auth"]

  provisioner "local-exec" "K8s_auth_backend" {
    command = "${path.module}/files/minikube_auth.sh"
  }
}

resource "local_file" "mongodb_kv" {
  content  = "${data.template_file.mongodb_kv.rendered}"
  filename = "${path.module}/files/mongodb_kv.sh"
}

resource "null_resource" "mongodb_kv" {
  depends_on = ["local_file.mongodb_kv", "vault_mount.kv_store"]

  provisioner "local-exec" "mongodb_kv" {
    command = "${path.module}/files/mongodb_kv.sh"
  }
}

resource "vault_policy" "fruits-catalog-static" {
  name = "fruits-catalog-static"

  policy = <<EOT
path "kv/fruits-catalog-mongodb" {
  capabilities = ["read"]
} 
EOT
}

resource "vault_kubernetes_auth_backend_role" "fruits-catalog" {
  backend                          = "${vault_auth_backend.minikube.path}"
  role_name                        = "fruits-catalog"
  bound_service_account_names      = ["${kubernetes_service_account.vault-auth.metadata.0.name}"]
  bound_service_account_namespaces = ["${var.namespace}"]
  policies                         = ["${vault_policy.fruits-catalog-static.name}"]
  ttl                              = 86400
}
