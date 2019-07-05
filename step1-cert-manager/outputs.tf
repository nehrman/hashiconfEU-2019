
output "vault_token_lease_duration" {
    value = "${vault_token.cert-manager.lease_duration}"
}