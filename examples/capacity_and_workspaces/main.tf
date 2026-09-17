terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.13"
    }
  }
}

provider "azapi" {}

provider "fabric" {}

provider "fabric" {
  alias                               = "global"
  use_workspace_private_link_endpoint = false
}

module "capacity" {
  source  = "Azure/avm-res-fabric-capacity/azure"
  version = "0.1.0"

  administration_members = var.capacity_administration_members
  location               = var.location
  name                   = var.capacity_name
  parent_id              = var.resource_group_id
  sku_name               = var.capacity_sku_name
  enable_telemetry       = var.enable_telemetry
}

data "fabric_capacity" "this" {
  provider = fabric.global

  display_name = module.capacity.name

  lifecycle {
    postcondition {
      condition     = self.state == "Active"
      error_message = "The shared Fabric capacity must be active before creating workspaces."
    }
  }
  depends_on = [module.capacity]
}

module "workspace" {
  source = "../../"
  providers = {
    fabric        = fabric
    fabric.global = fabric.global
  }
  for_each = var.workspaces

  capacity_id      = data.fabric_capacity.this.id
  name             = each.value.name
  description      = each.value.description
  enable_telemetry = var.enable_telemetry
}
