

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
  name                = var.eventhub_ns
  location            = data.azurerm_resource_group.rg_test.location
  resource_group_name = data.azurerm_resource_group.rg_test.name
  sku                 = "Standard"
  capacity            = 1

  tags = var.tags
}

resource "azurerm_eventhub" "shc_management_sub_activity_logs" {
  name                = var.eventhub
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.rg_test.name
  partition_count     = 2
  message_retention   = 1
}



data "azurerm_eventhub_namespace_authorization_rule" "rule_id" {
  name                = "RootManageSharedAccessKey" // default name, created by eventhub namespace
  namespace_name      = azurerm_eventhub_namespace.splunklogs_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.rg_test.name
}


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
/*data "azurerm_monitor_diagnostic_categories" "subs" {
    resource_id = "/subscriptions/00a68851-3686-4442-9966-7ed17046b956/providers/microsoft.insights/diagnosticSettings/azure_monitor_diag"
}
*/

resource "azurerm_monitor_diagnostic_setting" "subscription" {
  name                           = "azure_monitor_diag"
  target_resource_id             = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  eventhub_name                  = azurerm_eventhub.shc_management_sub_activity_logs.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.splunk_shared_access_key.id
  storage_account_id             = azurerm_storage_account.sargtest1000.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.casdeone_law.id

  /*used with data block to create dynamic block -- in progress
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


//spn role assignment

data "azuread_service_principal" "spn_splunk_app" {
  display_name = "azure-cli-2022-11-06-03-25-57"
}
resource "azurerm_role_assignment" "shc_splunk_app_ra_reader" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.spn_splunk_app.object_id
}

resource "azurerm_role_assignment" "shc_splunk_app_ra_data_reciever" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = data.azuread_service_principal.spn_splunk_app.object_id
}




// azure require tagging policy
// /providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99
// Require a tag on resources


/*
resource "azurerm_management_group_policy_assignment" "shc_require_tags" {
  #for_each = toset(var.required_tags)
  name                 = "shc_require_tags"
  management_group_id  = data.azurerm_management_group.mg-management.id
  policy_definition_id = data.azurerm_policy_definition.shc_policy_require_tags.id
  #for_each = toset(var.required_tags)
  parameters = <<PARAMS
    {
      "tagName": {
        "value": "${var.required_tags}"
      }
    }
PARAMS
}
*/

resource "azurerm_policy_definition" "shc_vm_require_tags_def" {
  name                = "shc_vm_require_tags_policy"
  management_group_id = data.azurerm_management_group.mg-management.id
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "SHC Require a tag on vm resources"
  metadata            = file("./policy_definitions/shc_vm_required_tags/metadata.json")
  policy_rule         = file("./policy_definitions/shc_vm_required_tags/policy_rule.json")
  parameters          = file("./policy_definitions/shc_vm_required_tags/parameters.json")
}


resource "azurerm_policy_definition" "shc_require_tags_def" {
  name                = "shc_vm_require_tags"
  management_group_id = data.azurerm_management_group.mg-management.id
  mode                = "Indexed"
  policy_type         = "Custom"
  display_name        = "SHC Require a tag on resources"
  metadata            = file("./policy_definitions/shc_required_tags/metadata.json")
  policy_rule         = file("./policy_definitions/shc_required_tags/policy_rule.json")
  parameters          = file("./policy_definitions/shc_required_tags/parameters.json")
}

resource "azurerm_management_group_policy_assignment" "vm_policy" {
  name                 = "shc-vm-policy"
  policy_definition_id = azurerm_policy_definition.shc_vm_require_tags_def.id
  management_group_id  = data.azurerm_management_group.mg-management.id
  parameters           = file("./policy_definitions/shc_vm_required_tags/shc_vm_required_tags.parameters.json")
  /*
  parameters           = <<PARAMS
    {
      "tagName1": {
        "value": "backup"
      },
       "tagName2": {
        "value": "dns_name"
      },
       "tagName3": {
        "value": "shcappusage"
      },
       "tagName4": {
        "value": "shcsecuirtycompliance"
      },
       "tagName5": {
        "value": "data_classification"
      }
    }
PARAMS
*/
}

#test
resource "azurerm_management_group_policy_assignment" "required_policy" {
  name                 = "shc-required-policy"
  policy_definition_id = azurerm_policy_definition.shc_require_tags_def.id
  management_group_id  = data.azurerm_management_group.mg-management.id
  parameters           = file("./policy_definitions/shc_required_tags/shc_required_tags.parameters.json")

  /*
  parameters           = <<PARAMS
    {
      "tagName1": {
        "value": "business_criticality"
      },
       "tagName2": {
        "value": "application"
      },
       "tagName3": {
        "value": "responsible_group_manager"
      },
       "tagName4": {
        "value": "responsible_group_org_name"
      },
       "tagName5": {
        "value": "deployed_by"
      },
       "tagName6": {
        "value": "value_stream"
      }
    }
PARAMS
*/
}

// assign cis_140 policy to mg root

resource "azurerm_management_group_policy_assignment" "dev_cis140" {
  name                 = "dev_cis140"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/c3f5c4d9-9a1d-4a99-85c0-7f93e384d5c5"
  management_group_id  = data.azurerm_management_group.mg-management.id
}
