output "storage_account_name" {
  value     = azurerm_storage_account.table_data.name
  sensitive = false
}
output "storage_account_id" {
  value     = azurerm_storage_account.table_data.id
  sensitive = false
}
