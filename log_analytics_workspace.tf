### Requirements:

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54.0" # Tested on this provider version, but will allow future patch versions.
    }
  }
  required_version = "~> 1.14.0" # Tested on this Terraform CLI version, but will allow future patch versions.
}

### Data:

### Resources:

resource "azurerm_log_analytics_workspace" "this" {
  for_each = local.log_analytics_workspaces

  ### Basic

  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  tags                = each.value.tags

  ### Access

  allow_resource_only_permissions = each.value.allow_resource_only_permissions
  cmk_for_query_forced            = each.value.cmk_for_query_forced
  dynamic "identity" {
    for_each = each.value.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  internet_ingestion_enabled   = each.value.internet_ingestion_enabled
  internet_query_enabled       = each.value.internet_query_enabled
  local_authentication_enabled = each.value.local_authentication_enabled

  ### Retention/Quota

  daily_quota_gb                          = each.value.daily_quota_gb
  data_collection_rule_id                 = each.value.data_collection_rule_id
  immediate_data_purge_on_30_days_enabled = each.value.immediate_data_purge_on_30_days_enabled
  reservation_capacity_in_gb_per_day      = each.value.reservation_capacity_in_gb_per_day
  retention_in_days                       = each.value.retention_in_days
}

##### Role Assignments

module "lupus_az_role_assignment" {
  source   = "../lupus_az_role_assignment"
  for_each = local.role_assignments

  role_assignments = [for role in each.value : merge(role, {
    scope = azurerm_log_analytics_workspace.this[each.key].id
    # Create a unique ID for each role assignment to avoid collisions, we can't use scope since it isn't known a new resource.
    unique_for_each_id = format("%s>%s>%s", each.key, role.principal_id, coalesce(try(role.role_definition_name, null), try(role.role_definition_id, null)))
  })]
}

