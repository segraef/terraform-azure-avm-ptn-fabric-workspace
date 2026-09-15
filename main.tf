resource "fabric_workspace" "this" {
  display_name = var.name
  capacity_id  = var.capacity_id
  description  = var.description
  identity     = var.workspace_identity_enabled ? { type = "SystemAssigned" } : null
}

resource "fabric_workspace_role_assignment" "this" {
  for_each = var.workspace_role_assignments

  workspace_id = fabric_workspace.this.id
  principal = {
    id   = each.value.principal_id
    type = each.value.principal_type
  }
  role = each.value.role

  depends_on = [azapi_resource.private_dns_zone_group, azapi_resource.private_endpoint]
}
