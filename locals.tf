# Helps to combine data, easier debug and remove complexity in the main resource.

locals {
  log_analytics_workspaces_list = [
    for index, log_analytics_workspace in var.log_analytics_workspaces : {
      # Most will try and use key/value log_analytics_workspace first, then try applicable defaults and then null as a last resort.

      ### Basic

      index               = index # Added in case it's ever needed, since for_each/for loops don't have inherent indexes.
      location            = try(coalesce(log_analytics_workspace.location, try(var.defaults.location, null)), null)
      name                = log_analytics_workspace.name
      resource_group_name = try(coalesce(log_analytics_workspace.resource_group_name, try(var.defaults.resource_group_name, null)), null)
      sku                 = log_analytics_workspace.sku
      # Merges log_analytics_workspace or default tags with required tags.
      tags = merge(
        # Count log_analytics_workspace tags, if greater than 0 use them, otherwise try defaults tags if they exist, if not use a blank map. 
        length(log_analytics_workspace.tags) > 0 ? log_analytics_workspace.tags : try(var.defaults.tags, {}),
        try(var.required.tags, {})
      )

      ### Access

      allow_resource_only_permissions = log_analytics_workspace.allow_resource_only_permissions
      cmk_for_query_forced            = log_analytics_workspace.cmk_for_query_forced
      # This object is going to be encased in a list for dynamic block requirements, despite always being a single item.
      # The input variable is not required to be in a list for a better user experience since it's not needed or logical.
      #
      # If object is null, provide an empty list. Otherwise, make a list of the object.
      identity                     = log_analytics_workspace.identity == null ? [] : [log_analytics_workspace.identity]
      internet_ingestion_enabled   = log_analytics_workspace.internet_ingestion_enabled
      internet_query_enabled       = log_analytics_workspace.internet_query_enabled
      local_authentication_enabled = log_analytics_workspace.local_authentication_enabled

      ### Retention/Quota

      daily_quota_gb                          = log_analytics_workspace.daily_quota_gb
      data_collection_rule_id                 = log_analytics_workspace.data_collection_rule_id
      immediate_data_purge_on_30_days_enabled = log_analytics_workspace.immediate_data_purge_on_30_days_enabled
      reservation_capacity_in_gb_per_day      = log_analytics_workspace.reservation_capacity_in_gb_per_day
      retention_in_days                       = log_analytics_workspace.retention_in_days

      ###### Role Assignments

      role_assignments = log_analytics_workspace.role_assignments
    }
  ]

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  log_analytics_workspaces = {
    for log_analytics_workspace in local.log_analytics_workspaces_list : "${log_analytics_workspace.resource_group_name}>${log_analytics_workspace.name}" => log_analytics_workspace
  }

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  # Filters out any empty role assignment lists.
  role_assignments = {
    for log_analytics_workspace in local.log_analytics_workspaces_list : "${log_analytics_workspace.resource_group_name}>${log_analytics_workspace.name}" => log_analytics_workspace.role_assignments if length(log_analytics_workspace.role_assignments) > 0
  }
}