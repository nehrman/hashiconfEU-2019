variable "vault_token" {
  description = "Token for connectiong to Vault"
  default     = ""
}

variable "vault_addr" {
  description = "Vault Address to connect to"
  default     = "192.168.1.18:8300"
}

variable "namespace" {
  description = "Namespace where to deploy thongs on K8s"
  default     = "fruits-catalog"
}
