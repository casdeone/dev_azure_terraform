terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
  cloud {
    organization = "denniscastillo"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}