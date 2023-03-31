variable "tags" {
  type        = map(any)
  description = "Resource Tags"
}
variable "infrastructure_encryption_key_vault_id" {
  type        = string
  description = "ID of Key Vault in which to store the encryption key"
}
variable "infrastructure_encryption_key_type" {
  type        = string
  description = "Infra Encryption key type"
  default     = "RSA"
}
variable "infrastructure_encryption_key_size" {
  type        = string
  description = "Infra Encryption Key size"
  default     = "4096"
}
variable "infrastructure_encryption_key_opts" {
  type    = list(string)
  default = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
}
variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  default     = "Standard"
}
variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  default     = "LRS"
}
variable "min_tls_version" {
  type        = string
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts."
  default     = "TLS1_2"
}
variable "identity_ids" {
  type        = list(string)
  description = "List of user assigned identity ids"
}
variable "tables" {
  type        = list(string)
  description = "list of table names"
}
variable "location" {
  type        = string
  description = "Azure region to use"
}
variable "environment" {
  type        = string
  description = "Name of the environment - dev/live"
}
variable "company_tag" {
  type        = string
  description = "short name for the company"
  default     = "comp"

  validation {
    condition     = can(regex("^[a-z0-9]{2,4}$", var.company_tag))
    error_message = "The value of company_tag must be between 2 and 4 characters long and all lower case    . Regex Pattern: ^[a-z0-9]{2,4}$"
  }
}
variable "workload" {
  type        = string
  description = "name of the workload, this value must not contain spaces, it is used to build resource names"

  validation {
    condition     = length(var.workload) <= 20 && length(var.workload) >= 2
    error_message = "The value of company_tag must be between 2 and 4 characters long."
  }
}
