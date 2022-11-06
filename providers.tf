terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
  cloud {
    organization = "denniscastillo"
    workspaces {
        name = "dev_azure_terraform"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}