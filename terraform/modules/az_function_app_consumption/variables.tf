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
variable "account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  default     = "Standard"
}
variable "account_replication_type" {
  type        = string
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  default     = "ZRS"
}
variable "min_tls_version" {
  type        = string
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts."
  default     = "TLS1_2"
}
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
}
variable "msi_ids" {
  type        = list(string)
  description = "list of user assigned identies for infra encryption."
}
variable "infrastructure_encryption_key_vault_id" {
  type        = string
  description = "Key Vault id for infra encryption keys/secrets"
}
variable "app_settings" {
  type        = map(any)
  description = "Function App App Settings - key value pairs."
  default     = {}
}
variable "tags" {
  type        = map(any)
  description = "Resource Tags"
  default     = {}
}


# account_tier
# account_replication_type
# location
