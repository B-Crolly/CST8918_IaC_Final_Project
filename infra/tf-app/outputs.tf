#NOTE: outputs must be defined at every level of the module hierarchy, so here (root), and in the network module
# Define output values for later reference
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip" {
  value = module.network.public_ip_address
}

# Network module outputs
output "vnet_id" {
  value = module.network.vnet_id
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
