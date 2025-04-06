variable "label_prefix" {
  type        = string
  description = "Prefix for naming Azure resources"
}

variable "location" {
  type        = string
  description = "Azure region where AKS will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group for AKS clusters"
}

variable "test_subnet_id" {
  type        = string
  description = "Subnet ID for the test AKS cluster"
}

variable "prod_subnet_id" {
  type        = string
  description = "Subnet ID for the production AKS cluster"
}