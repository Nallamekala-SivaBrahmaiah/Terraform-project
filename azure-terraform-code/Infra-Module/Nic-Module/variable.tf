variable "nic_name" {
  description = "Network Interface name"
  type        = string
}

variable "loc_name" {
  description = "Azure location"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID"
  type        = string
}
