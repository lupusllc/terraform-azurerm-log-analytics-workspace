# Helps to combine data, easier debug and remove complexity in the main resource.

locals {
  log_analytics_workspaces_list = [
    for index, settings in var.log_analytics_workspaces : {
      # Most will try and use key/value settings first, then try applicable defaults and then null as a last resort.

      ### Basic

      index               = index # Added in case it's ever needed, since for_each/for loops don't have inherent indexes.
      location            = try(coalesce(settings.location, try(var.defaults.location, null)), null)
      name                = settings.name
      resource_group_name = try(coalesce(settings.resource_group_name, try(var.defaults.resource_group_name, null)), null)
      sku                 = settings.sku
      # Merges settings or default tags with required tags.
      tags = merge(
        # Count settings tags, if greater than 0 use them, otherwise try defaults tags if they exist, if not use a blank map. 
        length(settings.tags) > 0 ? settings.tags : try(var.defaults.tags, {}),
        try(var.required.tags, {})
      )

      ### Access

      allow_resource_only_permissions = settings.allow_resource_only_permissions
      cmk_for_query_forced            = settings.cmk_for_query_forced
      identity                        = settings.identity
      internet_ingestion_enabled      = settings.internet_ingestion_enabled
      internet_query_enabled          = settings.internet_query_enabled
      local_authentication_enabled    = settings.local_authentication_enabled

      ### Retention/Quota

      daily_quota_gb                          = settings.daily_quota_gb
      data_collection_rule_id                 = settings.data_collection_rule_id
      immediate_data_purge_on_30_days_enabled = settings.immediate_data_purge_on_30_days_enabled
      reservation_capacity_in_gb_per_day      = settings.reservation_capacity_in_gb_per_day
      retention_in_days                       = settings.retention_in_days

      ###### Role Assignments

      role_assignments = settings.role_assignments
    }
  ]

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  log_analytics_workspaces = {
    for index, settings in local.log_analytics_workspaces_list : "${settings.resource_group_name}>${settings.name}" => settings
  }

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  # Filters out any empty role assignment lists.
  role_assignments = {
    for index, settings in local.log_analytics_workspaces_list : "${settings.resource_group_name}>${settings.name}" => settings.role_assignments if length(settings.role_assignments) > 0
  }
}