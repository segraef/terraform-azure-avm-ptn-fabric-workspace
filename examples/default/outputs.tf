output "workspace_id" {
  description = "Created Fabric workspace GUID."
  value       = module.workspace.workspace_id
}

output "workspace_identity" {
  description = "Workspace identity for separately managed destination permissions."
  value       = module.workspace.workspace_identity
}
