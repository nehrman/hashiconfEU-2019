
output "vault_token_lease_duration" {
    value = "${vault_token.fruits-catalog.lease_duration}"
}

output "mongodb_admin_password" {
    value = "${random_string.mongodb-adm-password.result}"
}
