resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.loc_name
  sku                 = "Standard"
  admin_enabled       = true
}