variable "vault_token" {
  description = "Token for connectiong to Vault"
  default     = ""
}

variable "vault_addr" {
  description = "Vault Address to connect to"
  default     = "192.168.94.141:8200"
}

variable "namespace" {
  description = "Namespace where to deploy things on K8s"
  default     = "fruits-catalog"
}

variable "name" {
  description = "Name of the certificate configuration"
  default     = "fruits-certificate"
}

variable "secretname" {
  description = "Name of the K8s secret"
  default     = "fruits-certificate"
}

variable "commonname" {
  description = "Common Name used for certificates"
  default     = "testlab.local"
}

variable "dns_names" {
  description = "Dns Names used for certificates"
  default     = "fruits"
}

variable "database_name" {
  description = "MongoDB Database name"
  default     = "sampledb"
}

variable "database_user" {
  description = "MongoDB Database username"
  default     = "userEVY"
}
