# referenced from: http://k8s.anjikeesari.com/azure/14-redis-cache/#task-1-define-and-declare-azure-cache-for-redis-variables

# Handled variables from module declaration

variable "resource_group_name" {
  description = "(Required) Resource group name where Redis will be deployed to."
  type        = string
}

variable "location" {
  type        = string
  description = "(Required) Azure region where Redis will be deployed"
}

variable "label_prefix" {
  type        = string
  description = "(Required) Prefix for naming Azure resources"
}

variable "vnet_name" {
  type        = string
  description = "(Required) Name for the VNet Redis will use."
}

variable "vnet_id" {
  type        = string
  description = "(Required) Id for the VNet Redis will use."
}

variable "subnet_id" {
  type        = string
  description = "(Required) The ID of the Subnet from which Private IP Addresses will be allocated for Redis' Private Endpoint."
}

# Other required/optional variables from reference

variable "redis_cache_enabled" {
  description = "(Optional) Whether to enable or disable redis_cache resource creations"
  type        = bool
  default     = false
}
variable "redis_cache_prefix" {
  type        = string
  default     = "redis"
  description = "Prefix of the Redis cache name that's combined with name of the Redis Cache."
}

variable "redis_cache_sku" {
  description = " (Required) The SKU of Redis to use. Possible values are Basic, Standard and Premium."
  default     = "Basic"
  type        = string
}

variable "redis_cache_capacity" {
  description = "(Required) The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  default     = "2"
  type        = string
}

variable "redis_cache_family" {
  description = " (Required) The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)"
  default     = "C"
  type        = string
}
variable "request_message" {
  description = "(Optional) Specifies a message passed to the owner of the remote resource when the private endpoint attempts to establish the connection to the remote resource."
  type        = string
  default     = null
}

variable "redis_public_network_access_enabled" {
  description = " (Optional) Whether or not public network access is allowed for this Redis Cache. true means this resource could be accessed by both public and private endpoint. false means only private endpoint access is allowed. Defaults to true."
  type        = bool
  default     = false
}
variable "redis_enable_authentication" {
  description = " (Optional) If set to false, the Redis instance will be accessible without authentication. Defaults to true."
  type        = bool
  default     = true
}
variable "redis_pe_core_enabled" {
  description = " (Optional) Enable core subscription private endpoint"
  type        = bool
  default     = false
}
variable "private_endpoint_prefix" {
  type        = string
  default     = "pe"
  description = "Prefix of the Private Endpoint name that's combined with name of the Private Endpoint."
}