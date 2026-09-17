output "capacity_id" {
  description = "Fabric capacity GUID used for workspace assignment, not its ARM resource ID."
  value       = data.fabric_capacity.this.id
}

output "capacity_resource_id" {
  description = "ARM resource ID of the shared capacity."
  value       = module.capacity.resource_id
}

output "workspace_ids" {
  description = "Workspace GUIDs keyed by the caller's stable names."
  value       = { for key, workspace in module.workspace : key => workspace.workspace_id }
}
