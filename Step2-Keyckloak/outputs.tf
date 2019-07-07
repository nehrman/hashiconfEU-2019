output "keycloak_admin_password" {
    value = "${random_string.adminkc.result}"
}