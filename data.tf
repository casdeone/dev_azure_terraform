data "azurerm_resource_group" "rg_test" {
  name = "rg-test"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_policy_definition" "shc_policy_require_tags" {
  display_name = "Require a tag on resources"

}
data "azurerm_management_group" "mg-management" {
  display_name = "mg-root"

}