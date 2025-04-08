output "private_endpoint_test_id" {
    description = "Private Endpoint Id of Redis for the test environment."
    value       = azurerm_private_endpoint.pe_redis_test.id
}
output "private_endpoint_prod_id" {
    description = "Private Endpoint Id of Redis for the production environment."
    value       = azurerm_private_endpoint.pe_redis_prod.id
}

# todo