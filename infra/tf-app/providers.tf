# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6" #"2.3.3  use this version if the weather api is having version problems"
    }
  }

}

# Define providers and their config params
provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {}
  use_oidc        = true
  subscription_id = "baa2e491-8289-482b-8458-84a427f52aa1"
}

provider "cloudinit" {
  # Configuration options
}
