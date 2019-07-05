
output "vault_token_lease_duration" {
    value = "${vault_token.fruits-catalog.lease_duration}"
}