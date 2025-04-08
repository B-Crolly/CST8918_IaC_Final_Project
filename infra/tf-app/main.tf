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

# Call AKS module (uncommented and ready to use)
module "aks" {
  source              = "./modules/aks"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  test_subnet_id      = module.network.test_subnet_id
  prod_subnet_id      = module.network.prod_subnet_id
}

# todo add module redis here

# Call application module (commented out until implemented)
# module "application" {
#   source              = "./modules/application"
#   label_prefix        = var.labelPrefix
#   location            = var.region
#   resource_group_name = azurerm_resource_group.rg.name
#   test_cluster_id     = module.aks.test_cluster_id
#   prod_cluster_id     = module.aks.prod_cluster_id
#   test_kube_config    = module.aks.test_kube_config
#   prod_kube_config    = module.aks.prod_kube_config
# } 