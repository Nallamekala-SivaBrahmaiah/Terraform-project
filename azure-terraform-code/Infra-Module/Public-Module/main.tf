resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  location            = var.loc_name
  resource_group_name = var.rg_name
  allocation_method   = var.allocation_method
}