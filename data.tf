data "azurerm_resource_group" "rg_test" {
  name = "rg-test"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}