# AKS Module - Variables
# label_prefix - Prefix for resource names
# location - Azure region
# resource_group_name - Name of the resource group
# test_subnet_id - ID of the test subnet
# prod_subnet_id - ID of the production subnet

variable "label_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
} 