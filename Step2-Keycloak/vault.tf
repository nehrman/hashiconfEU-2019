resource "vault_pki_secret_backend_role" "keycloak" {
  backend        = "pki_int"
  name           = "keycloak"
  ttl            = 86400
  allow_any_name = "true"
  allow_subdomains = "true"
  generate_lease = "true"
}

resource "vault_token" "keycloak" {
  policies = ["fruits-catalog"]

  renewable = true
  ttl       = "24h"

  renew_min_lease = 43200
  renew_increment = 86400
}
