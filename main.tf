
// azure storage account

resource "azurerm_storage_account" "sargtest1000" {
  name                     = "sargtest1000"
  resource_group_name      = data.azurerm_resource_group.rg_test.name
  location                 = data.azurerm_resource_group.rg_test.location
  account_tier             = "Standard"
  account_replication_type = "LRS" // ??? GRS is default $$$

  tags = var.tags
}

//azure eventhub

resource "azurerm_eventhub_namespace" "splunklogs_eventhub_ns" {
  name                = "splunklogs-eventhub"
  location            = data.azurerm_resource_group.rg_test.location
  resource_group_name = data.azurerm_resource_group.rg_test.name
  sku                 = "Standard"
  capacity            = 1

  tags = var.tags
}

resource "azurerm_eventhub" "shc_management_sub_activity_logs" {
  name                = "shc-management-sub-activiy-logs"
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.rg_test.name
  partition_count     = 2
  message_retention   = 1
}

/*
data "azurerm_eventhub_namespace_authorization_rule" "rule_id" {
  name                = "RootManageSharedAccessKey" // default name, created by eventhub namespace
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.rg_test.name
}
*/

resource "azurerm_eventhub_namespace_authorization_rule" "splunk_shared_access_key" {
  name                = "splunk-shared-access-key"
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.rg_test.name

  listen = true
  send   = true
  manage = false


}
// azure diagnostic setting

//use to refactor for dynamic log block -- in progress
/* data "azurerm_monitor_diagnostic_categories" "subs" {
    resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}
*/

resource "azurerm_monitor_diagnostic_setting" "subscription" {
  name                           = "azure_monitor_diag"
  target_resource_id             = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  eventhub_name                  = azurerm_eventhub.shc_management_sub_activity_logs.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.splunk_shared_access_key.id
  storage_account_id             = azurerm_storage_account.sargtest1000.id

  /* used with data block to create dynamic block -- in progress
  dynamic log {
    for_each = data.azurerm_monitor_diagnostic_categories.subs.logs
    content {
        category = log.value
    }
  }
 */

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
  log {
    category = "Policy"
    enabled  = true
  }
  log {
    category = "Autoscale"
    enabled  = true
  }
  log {
    category = "Recommendation"
    enabled  = true
  }

}