terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0"
    }
  }
}

# TEST Cluster (fixed at 1 node)
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.label_prefix}-aks-test"
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-test"
  
  # Override default node resource group name to shorten it
  node_resource_group = "${var.label_prefix}-aks-nodes-test"

  default_node_pool {
    name           = "testnp"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = var.test_subnet_id
  }

  # Specify a network profile to avoid service CIDR conflicts.
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.96.0.0/16"
    dns_service_ip = "10.96.0.10"
  }

  identity {
    type = "SystemAssigned"
  }
}

# PROD Cluster (autoscaling between 1 and 3 nodes)
resource "azurerm_kubernetes_cluster" "prod" {
  name                = "${var.label_prefix}-aks-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-prod"

  # Override default node resource group name to shorten it
  node_resource_group = "${var.label_prefix}-aks-nodes-prod"

  default_node_pool {
    name           = "prodnp"
    vm_size        = "Standard_B2s"
    vnet_subnet_id = var.prod_subnet_id

    # Set node_count to null and enable autoscaling
    node_count           = null
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
  }

  # Specify a network profile to avoid service CIDR conflicts.
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.96.0.0/16"
    dns_service_ip = "10.96.0.10"
  }

  identity {
    type = "SystemAssigned"
  }
}
