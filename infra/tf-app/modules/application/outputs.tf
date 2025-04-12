# Application Module - Outputs
# acr_login_server - ACR login server URL
# test_redis_host - Redis host for test environment
# test_redis_key - Redis access key for test environment
# prod_redis_host - Redis host for production environment
# prod_redis_key - Redis access key for production environment 

# Container Registry
output "acr_login_server" {
  description = "Login server for Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username for Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Admin password for Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# Test Environment
output "test_deployment_name" {
  description = "Name of the Kubernetes deployment in the test environment"
  value       = kubernetes_deployment.weather_app_test.metadata[0].name
}

output "test_service_name" {
  description = "Name of the Kubernetes service in the test environment"
  value       = kubernetes_service.weather_app_test.metadata[0].name
}

output "test_service_endpoint" {
  description = "Endpoint for the Kubernetes service in the test environment"
  value       = kubernetes_service.weather_app_test.spec[0].cluster_ip
}

# Production Environment
output "prod_deployment_name" {
  description = "Name of the Kubernetes deployment in the production environment"
  value       = kubernetes_deployment.weather_app_prod.metadata[0].name
}

output "prod_service_name" {
  description = "Name of the Kubernetes service in the production environment"
  value       = kubernetes_service.weather_app_prod.metadata[0].name
}

output "prod_service_endpoint" {
  description = "Endpoint for the Kubernetes service in the production environment"
  value       = kubernetes_service.weather_app_prod.status[0].load_balancer[0].ingress[0].ip
} 