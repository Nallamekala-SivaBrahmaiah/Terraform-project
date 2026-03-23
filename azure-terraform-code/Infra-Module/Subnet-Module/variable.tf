variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "address_prefixes" {
  description = "Subnet address prefixes"
  type        = list(string)
}
