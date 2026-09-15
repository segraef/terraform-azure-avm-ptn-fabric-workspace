mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      tenant_id = "33333333-3333-4333-8333-333333333333"
    }
  }
}
mock_provider "fabric" {
  mock_resource "fabric_workspace" {
    defaults = {
      id = "11111111-1111-4111-8111-111111111111"
    }
  }
}
mock_provider "fabric" {
  alias = "global"
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name        = "example-workspace"
  capacity_id = "22222222-2222-4222-8222-222222222222"
}

run "defaults" {
  command = apply

  assert {
    condition     = output.workspace_id == "11111111-1111-4111-8111-111111111111" && output.workspace_identity.type == "SystemAssigned"
    error_message = "The module must return its workspace ID and enable workspace identity by default."
  }

  assert {
    condition     = output.network_communication_policy.outbound.public_access_rules.default_action == "Allow" && length(fabric_workspace_git_outbound_policy.this) == 0
    error_message = "OAP must remain disabled unless explicitly requested."
  }
}

run "outbound_default_deny" {
  command = apply

  variables {
    outbound_access_protection = {}
    workspace_identity_enabled = false
  }

  assert {
    condition     = output.workspace_identity == null && output.network_communication_policy.outbound.public_access_rules.default_action == "Deny"
    error_message = "OAP must be independent of workspace identity."
  }

  assert {
    condition     = fabric_workspace_git_outbound_policy.this[0].default_action == "Deny" && fabric_workspace_outbound_gateway_rules.this[0].default_action == "Deny" && fabric_workspace_outbound_cloud_connection_rules.this[0].default_action == "Deny"
    error_message = "OAP must deny Git, unspecified gateways, and unspecified cloud connection types."
  }
}

run "reject_arm_capacity_id" {
  command = plan

  variables {
    capacity_id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Fabric/capacities/example"
  }

  expect_failures = [var.capacity_id]
}

run "explicit_outbound_exceptions" {
  command = apply

  variables {
    outbound_access_protection = {
      allow_git           = true
      allowed_gateway_ids = ["44444444-4444-4444-8444-444444444444"]
      cloud_connection_rules = {
        AzureDataLakeStorage = { allowed_hostname_patterns = ["example.dfs.core.windows.net"] }
        LakeHouse            = { allowed_workspace_ids = ["55555555-5555-4555-8555-555555555555"] }
      }
    }
    workspace_role_assignments = {
      readers = {
        principal_id   = "66666666-6666-4666-8666-666666666666"
        principal_type = "Group"
        role           = "Viewer"
      }
    }
    git = {
      connection_id   = "77777777-7777-4777-8777-777777777777"
      provider_type   = "GitHub"
      owner_name      = "example-org"
      repository_name = "analytics"
      branch_name     = "main"
    }
    managed_private_endpoints = {
      storage = {
        name                            = "storage-dfs"
        target_private_link_resource_id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Storage/storageAccounts/example"
        target_subresource_type         = "dfs"
      }
    }
  }

  assert {
    condition     = fabric_workspace_git_outbound_policy.this[0].default_action == "Allow" && fabric_workspace_git.this[0].git_credentials.source == "ConfiguredConnection"
    error_message = "Git must use explicit OAP consent and a configured connection."
  }

  assert {
    condition     = length(fabric_workspace_outbound_cloud_connection_rules.this[0].rules) == 2 && one(fabric_workspace_outbound_gateway_rules.this[0].allowed_gateways).id == "44444444-4444-4444-8444-444444444444"
    error_message = "Only the requested outbound rules and gateway must be configured."
  }

  assert {
    condition     = fabric_workspace_role_assignment.this["readers"].role == "Viewer" && fabric_workspace_managed_private_endpoint.this["storage"].target_subresource_type == "dfs"
    error_message = "Workspace roles and managed private endpoint targets must be propagated."
  }
}

run "reject_git_without_oap_consent" {
  command = plan

  variables {
    outbound_access_protection = {}
    git = {
      connection_id   = "77777777-7777-4777-8777-777777777777"
      provider_type   = "GitHub"
      owner_name      = "example-org"
      repository_name = "analytics"
      branch_name     = "main"
    }
  }

  expect_failures = [fabric_workspace_git.this]
}

run "reject_unverified_lockdown" {
  command = plan

  variables {
    public_network_access_enabled = false
  }

  expect_failures = [fabric_workspace_network_communication_policy.this]
}

run "private_bootstrap" {
  command = apply

  override_resource {
    target = azapi_resource.private_link[0]
    values = {
      id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Fabric/privateLinkServicesForFabric/fabric-private-link"
    }
  }

  override_resource {
    target = azapi_resource.private_endpoint["primary"]
    values = {
      id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Network/privateEndpoints/pe-fabric"
    }
  }

  variables {
    private_link = {
      name      = "fabric-private-link"
      parent_id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example"
      endpoints = {
        primary = {
          name                         = "pe-fabric"
          location                     = "australiaeast"
          subnet_resource_id           = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Network/virtualNetworks/example/subnets/private"
          private_dns_zone_resource_id = "/subscriptions/22222222-2222-4222-8222-222222222222/resourceGroups/example/providers/Microsoft.Network/privateDnsZones/privatelink.fabric.microsoft.com"
        }
      }
    }
    retry    = { error_message_regex = ["ScopeLocked"] }
    timeouts = { create = "30m" }
  }

  assert {
    condition     = output.private_access_pending_verification && length(output.private_endpoints) == 1 && length(azapi_resource.private_dns_zone_group) == 1
    error_message = "Bootstrap must create private networking without silently denying public inbound access."
  }

  assert {
    condition     = azapi_resource.private_link[0].body.properties.workspaceId == output.workspace_id && azapi_resource.private_link[0].body.properties.tenantId == "33333333-3333-4333-8333-333333333333"
    error_message = "Private Link must target the created workspace in the authenticated Azure tenant."
  }

  assert {
    condition     = azapi_resource.private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["workspace"] && azapi_resource.private_link[0].timeouts.create == "30m"
    error_message = "The endpoint must use the workspace subresource and honor AzAPI timeouts."
  }
}
