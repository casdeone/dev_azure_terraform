
resource "azurerm_log_analytics_workspace" "casdeone_law" {
  name                = "casdeone-laws"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg_test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}