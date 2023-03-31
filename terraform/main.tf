locals {
  resource_group_name = lower("${var.company_tag}-${var.workload}-${var.environment}-rg")
  tables              = ["awsrootaccounts"]
  tags = merge(
    {
      environment = var.environment
    },
    var.tags
  )
}

# resource group
resource "azurerm_resource_group" "function_app" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# stroage account for table storage
data "azurerm_key_vault" "infrastructure_encryption" {
  name                = var.infrastructure_encryption_key_vault_name
  resource_group_name = var.infrastructure_encryption_resource_group_name
}

data "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.infrastructure_encryption_user_assigned_identity_name
  resource_group_name = var.infrastructure_encryption_resource_group_name
}

module "table_storage" {
  source                                 = "./modules/az_storage_account_for_table_storage"
  infrastructure_encryption_key_vault_id = data.azurerm_key_vault.infrastructure_encryption.id
  identity_ids                           = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
  tables                                 = local.tables
  location                               = azurerm_resource_group.function_app.location
  resource_group_name                    = azurerm_resource_group.function_app.name
  environment                            = var.environment
  company_tag                            = var.company_tag
  workload                               = var.workload
  tags                                   = local.tags
}

# function app
module "function_app" {
  source                                 = "./modules/az_function_app_consumption"
  location                               = azurerm_resource_group.function_app.location
  resource_group_name                    = azurerm_resource_group.function_app.name
  msi_ids                                = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
  infrastructure_encryption_key_vault_id = data.azurerm_key_vault.infrastructure_encryption.id
  environment                            = var.environment
  company_tag                            = var.company_tag
  workload                               = var.workload
  app_settings = {
    table_name                      = local.tables[0]
    resource_group_name             = azurerm_resource_group.function_app.name
    storage_account_name            = module.table_storage.storage_account_name
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = true
    WEBSITE_RUN_FROM_PACKAGE        = 1
  }
  tags = local.tags
}

# rbac assignment for MSI to access storage account
resource "azurerm_role_assignment" "role_assignment" {
  scope                = module.table_storage.storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = module.function_app.msi_principal_id
}
