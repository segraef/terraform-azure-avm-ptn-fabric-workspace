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

module "workspace" {
  source = "../../"
  providers = {
    fabric        = fabric
    fabric.global = fabric.global
  }
  for_each = var.workspaces

  capacity_id      = var.capacity_id
  name             = each.value.name
  description      = each.value.description
  enable_telemetry = var.enable_telemetry
}
