output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "Created Fabric workspace GUID."
}

output "workspace_identity" {
  value       = module.workspace.workspace_identity
  description = "Workspace identity for separately managed destination permissions."
}
