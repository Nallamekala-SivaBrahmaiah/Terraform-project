variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "address_space" {
  description = "Address space for VNet"
  type        = list(string)
}

variable "loc_name" {
  description = "Azure location"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}