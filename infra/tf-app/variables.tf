# Define config variables
variable "labelPrefix" {
  type        = string
  default     = "cst8918-final-project-group-1"
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

# Weather API key - populated by GitHub Action
variable "weather_api_key" {
  type        = string
  default     = ""
  description = "API key for OpenWeather API"
  sensitive   = true
}

# Container image tag for versioning
variable "image_tag" {
  type        = string
  default     = "v0.1.0"
  description = "Version tag for the container image"
}
