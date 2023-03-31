output "msi_principal_id" {
  value     = azurerm_windows_function_app.windows_function_app.identity[0].principal_id
  sensitive = false
}
