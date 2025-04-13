#NOTE: outputs must be defined at every level of the module hierarchy, so here (root), and in the network module
# Define output values for later reference
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Resource group location"
  value       = azurerm_resource_group.rg.location
}

# Network module outputs
output "vnet_id" {
  description = "Virtual network ID"
  value       = module.network.vnet_id
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "prod_subnet_id" {
  value = module.network.prod_subnet_id
}

output "test_subnet_id" {
  value = module.network.test_subnet_id
}

output "dev_subnet_id" {
  value = module.network.dev_subnet_id
}

output "admin_subnet_id" {
  value = module.network.admin_subnet_id
}

# AKS module outputs
output "test_cluster_id" {
  description = "ID of the test AKS cluster"
  value       = module.aks.test_cluster_id
}

output "test_cluster_name" {
  description = "Name of the test AKS cluster"
  value       = module.aks.test_cluster_name
}

output "test_kube_config" {
  description = "Kubeconfig for the test AKS cluster"
  value       = module.aks.test_kube_config
  sensitive   = true
}

output "prod_cluster_id" {
  description = "ID of the production AKS cluster"
  value       = module.aks.prod_cluster_id
}

output "prod_cluster_name" {
  description = "Name of the production AKS cluster"
  value       = module.aks.prod_cluster_name
}

output "prod_kube_config" {
  description = "Kubeconfig for the production AKS cluster"
  value       = module.aks.prod_kube_config
  sensitive   = true
}

# Redis outputs
output "test_redis_name" {
  description = "Test Redis cache name"
  value       = module.redis.test_redis_name
}

output "prod_redis_name" {
  description = "Production Redis cache name"
  value       = module.redis.prod_redis_name
}

# Application outputs
output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = module.application.acr_login_server
}

output "test_service_endpoint" {
  description = "Test Kubernetes service endpoint"
  value       = module.application.test_service_endpoint
}

output "prod_service_endpoint" {
  description = "Production Kubernetes service endpoint"
  value       = module.application.prod_service_endpoint
}