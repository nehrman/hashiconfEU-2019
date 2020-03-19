resource "vault_mount" "mongodb" {
  type = "database"
  path = "mongodbconf"
}

resource "vault_database_secret_backend_connection" "mongodb" {
  depends_on    = ["kubernetes_service.mongodb-vault"]
  backend       = "${vault_mount.mongodb.path}"
  name          = "fruits-catalog-mongodb"
  allowed_roles = ["fruits-catalog-role"]

  mongodb {
    connection_url = "mongodb://${var.mongodb_username}:${var.mongodb_pwd}@${var.mongodb_host}:${var.mongodb_nodeport}/admin"
  }
}

resource "vault_database_secret_backend_role" "mongodb" {
  backend               = "${vault_mount.mongodb.path}"
  name                  = "fruits-catalog-role"
  db_name               = "${vault_database_secret_backend_connection.mongodb.name}"
  creation_statements   = ["{ \"db\": \"sampledb\", \"roles\": [{\"role\": \"readWrite\", \"db\": \"sampledb\"}]}"]
  revocation_statements = ["'{ \"db\": \"sampledb\" }'"]
  default_ttl           = 3600
  max_ttl               = 86400
}

resource "vault_kubernetes_auth_backend_role" "fruits-catalog" {
  backend                          = "minikube"
  role_name                        = "fruits-catalog"
  bound_service_account_names      = ["vault-auth"]
  bound_service_account_namespaces = ["${var.namespace}"]
  policies                         = ["fruits-catalog-dynamic", "fruits-catalog-static"]
  ttl                              = 86400
}

resource "vault_policy" "fruits-catalog-dynamic" {
  name = "fruits-catalog-dynamic"

  policy = <<EOT
path "mongodbconf/creds/fruits-catalog-role" {
  capabilities = ["read"]
}
path "sys/leases/renew" {
  capabilities = ["create"]
}
path "sys/leases/revoke" {
  capabilities = ["update"]
}
EOT
}
