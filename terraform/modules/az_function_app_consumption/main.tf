resource "random_string" "storage_account_name" {
  length  = 6
  special = false
}

locals {
  storage_account_name      = lower(replace("${var.company_tag}${random_string.storage_account_name.result}${var.environment}st", "-", ""))
  service_plan_name         = lower("${var.company_tag}-${var.workload}-${var.environment}-plan")
  application_insights_name = lower("${var.company_tag}-${var.workload}-${var.environment}-app-ins")
  function_app_name         = lower("${var.company_tag}-${var.workload}-${var.environment}-func")
  tags = merge(
    {},
    var.tags
  )
}

resource "azurerm_key_vault_key" "key_vault_key" {
  name         = "${local.storage_account_name}-data-encryption-key"
  key_vault_id = var.infrastructure_encryption_key_vault_id
  key_type     = "RSA"
  key_size     = "4096"
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey", ]
}

resource "azurerm_storage_account" "storage_account" {
  name                              = local.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  min_tls_version                   = var.min_tls_version
  infrastructure_encryption_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = var.msi_ids
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.key_vault_key.id
    user_assigned_identity_id = var.msi_ids[0]
  }

  tags = local.tags
}

resource "azurerm_service_plan" "service_plan" {
  name                = local.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_application_insights" "application_insights" {
  name                = local.application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_windows_function_app" "windows_function_app" {
  name                = local.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  site_config {
    application_stack {
      powershell_core_version = 7.2
    }

    application_insights_key = azurerm_application_insights.application_insights.instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = var.app_settings

  tags = local.tags
}
