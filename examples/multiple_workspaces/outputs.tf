output "workspace_ids" {
  value       = { for key, workspace in module.workspace : key => workspace.workspace_id }
  description = "Workspace GUIDs keyed by the caller's stable names."
}
