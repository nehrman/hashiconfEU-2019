resource "vault_mount" "mongodb" {
  type = "database"
  path = "mongodbconf"
}

resource "vault_database_secret_backend_connection" "mongodb" {
  backend       = "${vault_mount.mongodb.path}"
  name          = "fruits-catalog-mongodb"
  allowed_roles = ["fruits-catalog-role"]

  mongodb {
    connection_url = "mongodb://${var.mongodb_username}:${var.mongodb_pwd}@${var.mongodb_host}/admin"
  }
}

resource "vault_database_secret_backend_role" "mongodb" {
  backend               = "${vault_mount.mongodb.path}"
  name                  = "fruits-catalog-role"
  db_name               = "${vault_database_secret_backend_connection.mongodb.name}"
  creation_statements   = ["{ \"db\": \"sampledb\", \"roles\": [{\"role\": \"readWrite\", \"db\": \"sampledb\"}]}"]
  revocation_statements = ["'{ \"db\": \"sampledb\" }'"]
  default_ttl = 3600
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
