output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}
output "container_name" {
  value = azurerm_storage_container.container.name
}
output "container_id" {
  value = azurerm_storage_container.container.id
}
