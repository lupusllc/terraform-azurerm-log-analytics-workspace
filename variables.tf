### Defaults

variable "defaults" {
  default     = {} # Defaults to an empty map.
  description = "Defaults used for resources when nothing is specified for the resource."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type        = any
}

### Required

variable "required" {
  default     = {} # Defaults to an empty map.
  description = "Required resource values, as applicable."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type        = any
}

### Dependencies

### Resources

variable "log_analytics_workspaces" {
  default     = [] # Defaults to an empty list.
  description = "Log analytics workspaces."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type = list(object({
    ### Basic

    location            = optional(string)
    name                = string
    resource_group_name = optional(string, null)
    sku                 = optional(string, "PerGB2018") # PerGB2018, PerNode, Premium, Standalone, Standard, CapacityReservation, LACluster. Default is PerGB2018.
    tags                = optional(map(string), {})

    ### Access

    allow_resource_only_permissions = optional(bool, true)  # Allows users to access to resource data that they have permissions to, even if they don't have access to the workspace itself. Default is true.
    cmk_for_query_forced            = optional(bool, false) # Customer Managed Storage mandatory for query management. Default is false.
    identity = optional(list(object({
      type         = string                     # SystemAssigned, UserAssigned.
      identity_ids = optional(list(string), []) # Required if type is UserAssigned.
    })), [])
    internet_ingestion_enabled   = optional(bool, true) # Allows ingestion over the internet. Default is true.
    internet_query_enabled       = optional(bool, true) # Allows queries over the internet. Default
    local_authentication_enabled = optional(bool, true) # Allows local authentication for the workspace, in addition to EntraID. Default is true.

    ### Retention/Quota

    daily_quota_gb                          = optional(number, -1)   # Daily data ingestion quota in GB. Default is -1 (unlimited).
    data_collection_rule_id                 = optional(string, null) # If using a data collection rule.
    immediate_data_purge_on_30_days_enabled = optional(bool, false)  # Immediately purges data after retention period of 30 days. Default is false.
    reservation_capacity_in_gb_per_day      = optional(number, null) # Only works if sku is CapacityReservation.
    retention_in_days                       = optional(number, 30)   # 30-730 days. Default is 30.

    ###### Role Assignments

    # This allows role assignments to be assigned as part of this module, since scope is already known.
    role_assignments = optional(any, [])
  }))
}
