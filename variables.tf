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

    location            = optional(string, null) # Defaults to null, which attempts to use defaults.
    name                = string
    resource_group_name = optional(string, null) # Defaults to null, which attempts to use defaults.
    sku                 = optional(string, null) # PerGB2018, PerNode, Premium, Standalone, Standard, CapacityReservation, LACluster. Defaults to null for resource default of PerGB2018.
    tags                = optional(map(string), {})

    ### Access

    allow_resource_only_permissions = optional(bool, null) # Allows users to access to resource data that they have permissions to, even if they don't have access to the workspace itself. Defaults to null for resource default of true.
    cmk_for_query_forced            = optional(bool, null) # Customer Managed Storage mandatory for query management.Defaults to null for resource default false.
    identity = optional(object({
      type         = string                             # SystemAssigned, UserAssigned.
      identity_ids = optional(list(string), [])         # Required if type is UserAssigned.
    }), null)                                           # We can't use blank object or it will inject unwanted data, so null is used instead.
    internet_ingestion_enabled   = optional(bool, null) # Allows ingestion over the internet. Defaults to null for resource default of true.
    internet_query_enabled       = optional(bool, null) # Allows queries over the internet. Defaults to null for resource default of true.
    local_authentication_enabled = optional(bool, null) # Allows local authentication for the workspace, in addition to EntraID. Defaults to null for resource default of true.

    ### Retention/Quota

    daily_quota_gb                          = optional(number, null) # Daily data ingestion quota in GB. Defaults to null for resource default of -1 (unlimited).
    data_collection_rule_id                 = optional(string, null) # If using a data collection rule. Defaults to null for resource default of null (unconfirmed).
    immediate_data_purge_on_30_days_enabled = optional(bool, false)  # Immediately purges data after retention period of 30 days. Defaults to null for resource default of false.
    reservation_capacity_in_gb_per_day      = optional(number, null) # Only works if sku is CapacityReservation. Defaults to null for resource default of null (unconfirmed).
    retention_in_days                       = optional(number, 30)   # 30-730 days. Default is 30.

    ###### Role Assignments

    # This allows role assignments to be assigned as part of this module, since scope is already known.
    role_assignments = optional(any, [])
  }))
}
