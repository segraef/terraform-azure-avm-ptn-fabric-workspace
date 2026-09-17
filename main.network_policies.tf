resource "fabric_workspace_network_communication_policy" "this" {
  provider = fabric.global

  workspace_id = fabric_workspace.this.id
  inbound = {
    public_access_rules = { default_action = var.public_network_access_enabled ? "Allow" : "Deny" }
  }
  outbound = {
    public_access_rules = { default_action = var.outbound_access_protection == null ? "Allow" : "Deny" }
  }

  lifecycle {
    precondition {
      condition     = var.public_network_access_enabled || (var.private_access_verified && length(local.private_endpoints) > 0)
      error_message = "Denying public inbound access requires a private endpoint and private_access_verified = true after verifying routing, DNS, and provider private connectivity."
    }
  }
  depends_on = [fabric_workspace_role_assignment.this, azapi_resource.private_dns_zone_group, azapi_resource.private_endpoint]
}

resource "fabric_workspace_outbound_gateway_rules" "this" {
  count = var.outbound_access_protection == null ? 0 : 1

  workspace_id     = fabric_workspace.this.id
  default_action   = "Deny"
  allowed_gateways = [for gateway_id in var.outbound_access_protection.allowed_gateway_ids : { id = gateway_id }]

  depends_on = [fabric_workspace_network_communication_policy.this]
}

resource "fabric_workspace_outbound_cloud_connection_rules" "this" {
  count = var.outbound_access_protection == null ? 0 : 1

  workspace_id   = fabric_workspace.this.id
  default_action = "Deny"
  rules = [for connection_type, rule in var.outbound_access_protection.cloud_connection_rules : {
    connection_type    = connection_type
    default_action     = "Deny"
    allowed_endpoints  = [for hostname in rule.allowed_hostname_patterns : { hostname_pattern = hostname }]
    allowed_workspaces = [for workspace_id in rule.allowed_workspace_ids : { workspace_id = workspace_id }]
  }]

  depends_on = [fabric_workspace_network_communication_policy.this]
}

resource "fabric_workspace_git_outbound_policy" "this" {
  count = var.outbound_access_protection == null ? 0 : 1

  workspace_id   = fabric_workspace.this.id
  default_action = var.outbound_access_protection.allow_git ? "Allow" : "Deny"

  depends_on = [fabric_workspace_network_communication_policy.this]
}
