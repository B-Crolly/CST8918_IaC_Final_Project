terraform {
  required_version = ">= 1.0.0"

  backend "azurerm" {
    resource_group_name  = "cst8918-final-state-rg"
    storage_account_name = "iacstatestorage8918gr1"
    container_name       = "tfstate"
    key                  = "prod.app.tfstate"
    use_oidc             = true
    subscription_id      = "baa2e491-8289-482b-8458-84a427f52aa1"
  }
} 