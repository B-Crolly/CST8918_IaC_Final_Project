# Define config variables
variable "labelPrefix" {
  type        = string
  description = "cst8918-final-project-group-1"
}

variable "region" {
  default = "canadacentral"
}

variable "admin_username" {
  type        = string
  default     = "azureadmin"
  description = "The username for the local user account on the VM."
}
