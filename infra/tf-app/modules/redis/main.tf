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

resource "azurerm_redis_cache" "redis" {
  count                         = var.redis_cache_enabled ? 1 : 0
  name                          = lower("${var.redis_cache_prefix}-${var.label_prefix}-${local.environment}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  capacity                      = var.redis_cache_capacity
  family                        = var.redis_cache_family
  sku_name                      = var.redis_cache_sku
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.redis_public_network_access_enabled

  redis_configuration {
    enable_authentication = var.redis_enable_authentication
  }
}

resource "azurerm_private_dns_zone" "pdz_redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
}

# Create private virtual network link to vnet
resource "azurerm_private_dns_zone_virtual_network_link" "redis_pdz_vnet_link" {
  name                  = "privatelink_to_${vnet_name}"
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_redis.name
}

# Create private endpoint for Azure Cache for Redis
resource "azurerm_private_endpoint" "pe_redis_core" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis.name}")
  location            = azurerm_redis_cache.redis.location
  resource_group_name = azurerm_redis_cache.redis.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis.name}"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"] # This is the appropriate name for Azure Cache for Redis: https://learn.microsoft.com/en-ca/azure/private-link/private-endpoint-overview#private-link-resource
    request_message                = try(var.request_message, null)
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id]
  }

  depends_on = [
    azurerm_redis_cache.redis,
    azurerm_private_dns_zone.pdz_redis
  ]
}