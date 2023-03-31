resource "random_string" "storage_account_name" {
  length  = 6
  special = false
}

locals {
  storage_account_name = lower(replace("${var.company_tag}${random_string.storage_account_name.result}${var.environment}st", "-", ""))
  tags = merge(
    {},
    var.tags
  )
}

resource "azurerm_key_vault_key" "key_vault_key" {
  name         = "${local.storage_account_name}-data-encryption-key"
  key_vault_id = var.infrastructure_encryption_key_vault_id
  key_type     = var.infrastructure_encryption_key_type
  key_size     = var.infrastructure_encryption_key_size
  key_opts     = var.infrastructure_encryption_key_opts
}

resource "azurerm_storage_account" "table_data" {
  name                              = local.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  min_tls_version                   = var.min_tls_version
  infrastructure_encryption_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.key_vault_key.id
    user_assigned_identity_id = var.identity_ids[0]
  }

  tags = local.tags
}

resource "azurerm_storage_table" "data_table" {
  for_each             = toset(var.tables)
  name                 = each.key
  storage_account_name = azurerm_storage_account.table_data.name
}
