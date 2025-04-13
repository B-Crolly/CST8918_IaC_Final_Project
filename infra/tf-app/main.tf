# Create resource group for all resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-RG"
  location = var.region
}

# Call network module
module "network" {
  source              = "./modules/network"
  label_prefix        = var.labelPrefix
  region              = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

# Call AKS module
module "aks" {
  source              = "./modules/aks"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  test_subnet_id      = module.network.test_subnet_id
  prod_subnet_id      = module.network.prod_subnet_id
}

# Call Redis module
module "redis" {
  source              = "./modules/redis"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  redis_cache_prefix  = "weather"
  # Default values from existing module
  redis_cache_sku                     = "Basic"
  redis_cache_family                  = "C"
  redis_cache_capacity_test           = 0
  redis_cache_capacity_prod           = 1
  redis_public_network_access_enabled = true
  redis_enable_authentication         = true
  vnet_id                             = module.network.vnet_id
  vnet_name                           = module.network.vnet_name
  subnet_id_test                      = module.network.test_subnet_id
  subnet_id_prod                      = module.network.prod_subnet_id
}

# Call application module
module "application" {
  source              = "./modules/application"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  # AKS cluster principal IDs for ACR access
  test_cluster_principal_id = module.aks.test_cluster_principal_id
  prod_cluster_principal_id = module.aks.prod_cluster_principal_id

  # AKS cluster connection details from AKS module outputs
  test_cluster_host           = module.aks.test_kube_config_host
  test_client_certificate     = module.aks.test_kube_config_client_certificate
  test_client_key             = module.aks.test_kube_config_client_key
  test_cluster_ca_certificate = module.aks.test_kube_config_cluster_ca_certificate

  prod_cluster_host           = module.aks.prod_kube_config_host
  prod_client_certificate     = module.aks.prod_kube_config_client_certificate
  prod_client_key             = module.aks.prod_kube_config_client_key
  prod_cluster_ca_certificate = module.aks.prod_kube_config_cluster_ca_certificate

  # Redis connection info from Redis module outputs
  test_redis_host = module.redis.test_redis_host
  test_redis_port = module.redis.test_redis_ssl_port
  test_redis_key  = module.redis.test_redis_primary_key
  prod_redis_host = module.redis.prod_redis_host
  prod_redis_port = module.redis.prod_redis_ssl_port
  prod_redis_key  = module.redis.prod_redis_primary_key

  # Weather API key - will be populated by GitHub Action or from tfvars
  weather_api_key = var.weather_api_key

  # Container image settings
  image_tag      = var.image_tag
  container_port = 80
} 