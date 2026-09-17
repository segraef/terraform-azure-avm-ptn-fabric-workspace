output "workspace_ids" {
  description = "Workspace GUIDs keyed by the caller's stable names."
  value       = { for key, workspace in module.workspace : key => workspace.workspace_id }
}
