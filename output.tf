output "log_analytics_workspaces" {
  description = "The log analytics workspaces."
  value       = azurerm_log_analytics_workspace.this
}

output "log_analytics_workspace_role_assignments" {
  description = "The log analytics workspace role assignments."
  value = merge(
    [
      for name, results in module.lupus_az_role_assignment : results.role_assignments
    ]... # Unpack the list of lists into a single list.
  )
}

### Debug Only

output "var_log_analytics_workspaces" {
  value = var.log_analytics_workspaces
}

output "local_log_analytics_workspaces" {
  value = local.log_analytics_workspaces
}

output "local_log_analytics_workspace_role_assignments" {
  value = local.role_assignments
}
