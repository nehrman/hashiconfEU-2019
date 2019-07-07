variable "vault_token" {
  description = "Token for connectiong to Vault"
  default     = ""
}

variable "vault_addr" {
  description = "Vault Address to connect to"
  default     = "192.168.1.18:8300"
}

variable "mongodb_username" {
  description = "Username for administrator connection to mongodb"
  default     = "admin"
}

variable "mongodb_pwd" {
  description = "Password of admin user in Mongodb"
  default     = ""
}

variable "mongodb_host" {
  description = "Mongodb Server to connect to"
  default     = ""
}

