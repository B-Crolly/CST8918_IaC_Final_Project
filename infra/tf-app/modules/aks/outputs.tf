############################################################
# AKS Module - Outputs
#
# test_cluster_id     - ID of the test cluster
# test_cluster_name   - Name of the test cluster
# test_kube_config    - Kubeconfig for the test cluster
# prod_cluster_id     - ID of the production cluster
# prod_cluster_name   - Name of the production cluster
# prod_kube_config    - Kubeconfig for the production cluster
############################################################

output "test_cluster_id" {
  description = "ID of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.id
}

output "test_cluster_name" {
  description = "Name of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.name
}

output "test_kube_config" {
  description = "Kubeconfig for the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.kube_config_raw
  sensitive   = true
}

output "prod_cluster_id" {
  description = "ID of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.id
}

output "prod_cluster_name" {
  description = "Name of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.name
}

output "prod_kube_config" {
  description = "Kubeconfig for the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.kube_config_raw
  sensitive   = true
}
