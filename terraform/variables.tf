# tags (Azure)
variable "tags" {
  type        = map(any)
  description = "Tags for Azure resouces"
}

# Azure general Information
variable "tenant_id" {
  type        = string
  description = "Azure tenant id"
}
variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}
variable "client_id" {
  type        = string
  description = "Azure AD Service Principal that is being used to deploy and manage the resources"
}
variable "client_secret" {
  type        = string
  description = "Azure AD Service Principal secret that is being used to deploy and manage the resources"
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
variable "infrastructure_encryption_resource_group_name" {
  type        = string
  description = "Name of resource group that contains infrastructure encryption resources"
}
variable "infrastructure_encryption_user_assigned_identity_name" {
  type        = string
  description = "user assigned identity used for infrastructure encryption"
}
variable "infrastructure_encryption_key_vault_name" {
  type        = string
  description = "Key Vaul used for infrastructure encryption"
}
