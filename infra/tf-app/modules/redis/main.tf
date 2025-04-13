# Create Azure Cache for Redis using terraform
# referencecd from: http://k8s.anjikeesari.com/azure/14-redis-cache/#task-2-create-azure-cache-for-redis-using-terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0"
    }
  }
}

resource "azurerm_redis_cache" "redis_test" {
  #count                         = var.redis_cache_enabled ? 1 : 0
  name                          = lower("${var.redis_cache_prefix}-${var.label_prefix}-test")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  capacity                      = var.redis_cache_capacity_test
  family                        = var.redis_cache_family
  sku_name                      = var.redis_cache_sku
  non_ssl_port_enabled          = true
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.redis_public_network_access_enabled

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication
  }
}

resource "azurerm_redis_cache" "redis_prod" {
  #count                         = var.redis_cache_enabled ? 1 : 0
  name                          = lower("${var.redis_cache_prefix}-${var.label_prefix}-prod")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  capacity                      = var.redis_cache_capacity_prod
  family                        = var.redis_cache_family
  sku_name                      = var.redis_cache_sku
  non_ssl_port_enabled          = true
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.redis_public_network_access_enabled

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication
  }
}

resource "azurerm_private_dns_zone" "pdz_redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
}

# Create private virtual network link to vnet
resource "azurerm_private_dns_zone_virtual_network_link" "redis_pdz_vnet_link" {
  name                  = "privatelink_to_${var.vnet_name}"
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_redis.name
}

# Create private endpoint for Azure Cache for Redis, TEST environment
resource "azurerm_private_endpoint" "pe_redis_test" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis_test.name}")
  location            = azurerm_redis_cache.redis_test.location
  resource_group_name = azurerm_redis_cache.redis_test.resource_group_name
  subnet_id           = var.subnet_id_test

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_test.name}"
    private_connection_resource_id = azurerm_redis_cache.redis_test.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"] # This is the appropriate name for Azure Cache for Redis: https://learn.microsoft.com/en-ca/azure/private-link/private-endpoint-overview#private-link-resource
    request_message                = try(var.request_message, null)
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id]
  }

  depends_on = [
    azurerm_redis_cache.redis_test,
    azurerm_private_dns_zone.pdz_redis
  ]
}

# Create private endpoint for Azure Cache for Redis, PROD environment
resource "azurerm_private_endpoint" "pe_redis_prod" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis_prod.name}")
  location            = azurerm_redis_cache.redis_prod.location
  resource_group_name = azurerm_redis_cache.redis_prod.resource_group_name
  subnet_id           = var.subnet_id_prod

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_prod.name}"
    private_connection_resource_id = azurerm_redis_cache.redis_prod.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"] # This is the appropriate name for Azure Cache for Redis: https://learn.microsoft.com/en-ca/azure/private-link/private-endpoint-overview#private-link-resource
    request_message                = try(var.request_message, null)
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id]
  }

  depends_on = [
    azurerm_redis_cache.redis_prod,
    azurerm_private_dns_zone.pdz_redis
  ]
}