variable "keycloak_namespace" {
  description = "Name of the namespace used for Keycloak"
  default     = "keycloak"
}

variable "vault_token" {
  description = "Token for connectiong to Vault"
  default     = ""
}

variable "vault_addr" {
  description = "Vault Address to connect to"
  default     = "192.168.94.141:8200"
}

variable "namespace" {
  description = "Namespace where to deploy thongs on K8s"
  default     = "keycloak"
}

variable "name" {
  description = "Name of the certificate configuration"
  default     = "keycloak"
}

variable "secretname" {
  description = "Name of the K8s secret"
  default     = "keycloak-certificate"
}

variable "commonname" {
  description = "Common Name used for certificates"
  default     = "testlab.local"
}

variable "dns_names" {
  description = "Dns Names used for certificates"
  default     = "keycloak"
}