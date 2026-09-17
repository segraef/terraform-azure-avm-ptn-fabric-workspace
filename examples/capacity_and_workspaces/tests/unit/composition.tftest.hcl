mock_provider "azapi" {}

mock_provider "fabric" {
  mock_resource "fabric_workspace" {
    defaults = {
      id = "33333333-3333-3333-3333-333333333333"
    }
  }
}

mock_provider "fabric" {
  alias = "global"
}

mock_provider "random" {}

override_module {
  target = module.capacity
  outputs = {
    name        = "examplecapacity"
    resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Fabric/capacities/examplecapacity"
  }
}

override_data {
  target = data.fabric_capacity.this
  values = {
    id    = "11111111-1111-1111-1111-111111111111"
    state = "Active"
  }
}

variables {
  capacity_administration_members = ["22222222-2222-2222-2222-222222222222"]
  capacity_name                   = "examplecapacity"
  location                        = "westeurope"
  resource_group_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
  enable_telemetry                = false
}

run "shared_capacity" {
  command = apply

  assert {
    condition     = output.capacity_id == "11111111-1111-1111-1111-111111111111" && output.capacity_id != output.capacity_resource_id
    error_message = "Workspace assignment must use the Fabric capacity GUID, not the ARM resource ID."
  }

  assert {
    condition     = toset(keys(output.workspace_ids)) == toset(["development", "test"])
    error_message = "Both workspaces must be created against the shared capacity."
  }
}

run "reject_inactive_capacity" {
  command = plan

  override_data {
    target = data.fabric_capacity.this
    values = {
      id    = "11111111-1111-1111-1111-111111111111"
      state = "Inactive"
    }
  }

  expect_failures = [data.fabric_capacity.this]
}
