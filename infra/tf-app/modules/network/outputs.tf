output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "prod_subnet_id" {
  description = "ID of the production subnet"
  value       = azurerm_subnet.prod.id
}

output "test_subnet_id" {
  description = "ID of the test subnet"
  value       = azurerm_subnet.test.id
}

output "dev_subnet_id" {
  description = "ID of the development subnet"
  value       = azurerm_subnet.dev.id
}

output "admin_subnet_id" {
  description = "ID of the admin subnet"
  value       = azurerm_subnet.admin.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.webserver.id
}

output "public_ip_id" {
  description = "ID of the public IP address"
  value       = azurerm_public_ip.webserver.id
}

output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.webserver.ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.webserver.id
} 