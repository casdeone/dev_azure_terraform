variable "tags" {
  type = map(string)
  default = {
    "business_criticality"       = "high",
    "application"                = "splunk",
    "value_stream"               = "logging",
    "responsible_group_manager"  = "steven.simpauco@sharp.com",
    "responsible_group_org_name" = "dts",
    "deplyed_by"                 = "dennis.castillo@sharp.com"
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
  type =string
  default = "casdeone_eventhub"
}

variable "eventhub_ns" {
  type = string
  default = "casdeone_eventhub_ns"
}