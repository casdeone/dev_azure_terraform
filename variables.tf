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

variable "required_tags"{
  type =string
  description = "required tags"
  default ="business_criticality,application,deployed_by"
}