variable "tags" {
  type = map(string)
  default = {
    "business_criticality"       = "high",
    "application"                = "splunk",
    "value_stream"               = "logging",
    "responsible_group_manager"  = "steven.simpauco@sharp.com",
    "responsible_group_org_name" = "dts",
    "deployed_by"                 = "dennis.castillo@sharp.com"
  }
}

variable "vm_tags" {
  type = map(string)
  default = {
    //"backup"                    = "yes",
    //"dns_name"                   = "vm.casdeone.com",
    "shcappusage"                = "imaging",
    "shcsecuirtycompliance"      = "yes",
    "responsible_group_org_name" = "dts",
    "data_classification"        = "private"
  }
}

variable "required_tags" {
  type        = string
  description = "required tags"
  default     = "business_criticality,application,deployed_by,value_stream,responsible_group_manager,responsible_group_org_name"
}

variable "vm_required_tags" {
  type        = string
  description = "required tags"
  default     = "backup,dns_name,shcappusage,shcsecuirtycompliance,data_classification"
}

variable "tfe_team_token" {
  type        = string
  description = "tfe team token"
}

variable "eventhub" {
  type    = string
  default = "casdeone-eventhub"
}

variable "eventhub_ns" {
  type    = string
  default = "casdeone-eventhub-ns"
}

variable "location" {
  type        = string
  description = "location"
  default     = "West US 3"
}

// variable feature flag

variable "enable_feature_flag" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}

variable "enable_feature_flag_1" {
  type = number
  description = "(optional) describe your variable"
  default = 0
}