terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# TEST Cluster
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.label_prefix}-aks-test"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Replace "1.32.0" with a valid version if needed
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-test"

  default_node_pool {
    name            = "testnp"
    node_count      = 1
    vm_size         = "Standard_B2s"
    vnet_subnet_id  = var.test_subnet_id
  }
}

# PROD Cluster
resource "azurerm_kubernetes_cluster" "prod" {
  name                = "${var.label_prefix}-aks-prod"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Replace "1.32.0" with a valid version if needed
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-prod"

  default_node_pool {
    name                = "prodnp"
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    vnet_subnet_id      = var.prod_subnet_id
  }
}
