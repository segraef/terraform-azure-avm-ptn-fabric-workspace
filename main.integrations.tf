resource "fabric_workspace_git" "this" {
  count = var.git == null ? 0 : 1

  workspace_id            = fabric_workspace.this.id
  initialization_strategy = var.git.initialization_strategy
  git_provider_details = {
    git_provider_type = var.git.provider_type
    repository_name   = var.git.repository_name
    branch_name       = var.git.branch_name
    directory_name    = var.git.directory_name
    owner_name        = var.git.owner_name
    organization_name = var.git.organization_name
    project_name      = var.git.project_name
  }
  git_credentials = {
    source        = "ConfiguredConnection"
    connection_id = var.git.connection_id
  }

  depends_on = [fabric_workspace_network_communication_policy.this, fabric_workspace_git_outbound_policy.this]

  lifecycle {
    precondition {
      condition     = var.outbound_access_protection == null ? true : var.outbound_access_protection.allow_git
      error_message = "Git integration requires outbound_access_protection.allow_git = true when OAP is enabled."
    }
  }
}

resource "fabric_workspace_managed_private_endpoint" "this" {
  for_each = var.managed_private_endpoints

  workspace_id                    = fabric_workspace.this.id
  name                            = each.value.name
  target_private_link_resource_id = each.value.target_private_link_resource_id
  target_subresource_type         = each.value.target_subresource_type
  request_message                 = each.value.request_message

  depends_on = [fabric_workspace_network_communication_policy.this]
}
