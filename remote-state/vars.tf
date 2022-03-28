variable "resource_group_name" {
  description = "The name of the resource group to deploy the resources to"
  type = string
  default = "terraform-storage-rg"
}

variable "resource_group_location" {
  default     = "West Europe"
  description = "Where are the resources deployed"
}
