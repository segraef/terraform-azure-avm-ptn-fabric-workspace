output "git_connection_state" {
  description = "Git connection state returned by Fabric, or null if Git is not configured."
  value       = one(fabric_workspace_git.this[*].git_connection_state)
}

output "managed_private_endpoints" {
  description = "Managed private endpoint identifiers and approval/provisioning states. Pending endpoints require target-owner approval."
  value = { for key, endpoint in fabric_workspace_managed_private_endpoint.this : key => {
    id                 = endpoint.id
    provisioning_state = endpoint.provisioning_state
    connection_state   = endpoint.connection_state
  } }
}

output "network_communication_policy" {
  description = "Configured inbound and outbound workspace network policies."
  value = {
    inbound  = fabric_workspace_network_communication_policy.this.inbound
    outbound = fabric_workspace_network_communication_policy.this.outbound
  }
}

output "onelake_endpoints" {
  description = "OneLake blob and DFS endpoints returned by Fabric."
  value       = fabric_workspace.this.onelake_endpoints
}

output "private_access_pending_verification" {
  description = "True when private networking is configured but public inbound access remains allowed. Do not load sensitive data during this bootstrap state."
  value       = var.private_link != null && var.public_network_access_enabled
}

output "private_endpoints" {
  description = "Private endpoint ARM IDs and service-generated DNS/connection information; no IP mappings are fabricated."
  value = { for key, endpoint in azapi_resource.private_endpoint : key => {
    resource_id       = endpoint.id
    connection_config = endpoint.output
    dns_config        = try(azapi_resource.private_dns_zone_group[key].output, null)
  } }
}

output "private_link_resource_id" {
  description = "Azure resource ID of the workspace Private Link service, or null."
  value       = one(azapi_resource.private_link[*].id)
}

output "workspace_api_hostname" {
  description = "Workspace-specific Fabric API hostname for private DNS verification. The communication policy API still uses the global Fabric endpoint."
  value       = "${replace(fabric_workspace.this.id, "-", "")}.z${substr(fabric_workspace.this.id, 0, 2)}.w.api.fabric.microsoft.com"
}

output "workspace_id" {
  description = "Fabric workspace GUID. This is not an ARM resource ID."
  value       = fabric_workspace.this.id
}

output "workspace_identity" {
  description = "Fabric workspace identity type, application_id, and service_principal_id, or null if disabled."
  value       = fabric_workspace.this.identity
}
