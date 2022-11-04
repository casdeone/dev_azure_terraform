
// azure storage account

resource "azurerm_storage_account" "sargtest1000" {
  name                     = "sargtest1000"
  resource_group_name      = data.azurerm_resource_group.rg_test.name
  location                 = data.azurerm_resource_group.rg_test.location
  account_tier             = "Standard"
  account_replication_type = "LRS" // ??? GRS is default $$$

  tags = {
    environment = "prod"
  }
}

//azure eventhub

resource "azurerm_eventhub_namespace" "splunklogs_eventhub" {
  name                = "splunklogs-eventhub"
  location            = data.azurerm_resource_group.rg_test.location
  resource_group_name = data.azurerm_resource_group.rg_test.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "prod"
  }
}

resource "azurerm_eventhub" "azure_activity_logs" {
  name                = "azure-activiy-logs"
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub.name
  resource_group_name = data.azurerm_resource_group.rg_test.name
  partition_count     = 2
  message_retention   = 1
}

// azure diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "azure_monitor_diag" {
  name               = "azure_monitor_diag"
  target_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  eventhub_name      = azurerm_eventhub_namespace.splunklogs_eventhub.name
  storage_account_id = azurerm_storage_account.sargtest1000.id
// az monitor activity-log list-categories
  log {
    category = "Administrative"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
      category = "Security"
    enabled  = true
  }
   log {
      category = "ServiceHealth"
    enabled  = true
  }
  log {
      category = "Alert"
    enabled  = true
  }
  log {
      category = "ResourceHealth"
    enabled  = true
  }
}