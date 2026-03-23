output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "nic_private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}