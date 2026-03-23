variable "pip_name" {
  description = "Public IP name"
  type        = string
}

variable "loc_name" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "allocation_method" {
  description = "Static or Dynamic"
  type        = string
  default     = "Static"
}