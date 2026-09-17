data "azapi_client_config" "private_link" {
  count = var.private_link == null ? 0 : 1
}

resource "azapi_resource" "private_link" {
  count = var.private_link == null ? 0 : 1

  location  = "global"
  name      = var.private_link.name
  parent_id = var.private_link.parent_id
  type      = var.resource_types.fabric_private_link_services_for_fabric
  body = {
    properties = {
      tenantId    = data.azapi_client_config.private_link[0].tenant_id
      workspaceId = fabric_workspace.this.id
    }
  }
  ignore_body_changes       = length(var.ignore_body_changes.fabric_private_link_services_for_fabric) > 0 ? var.ignore_body_changes.fabric_private_link_services_for_fabric : null
  replace_triggers_refs     = ["properties.tenantId", "properties.workspaceId"]
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = false
  tags                      = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "private_endpoint" {
  for_each = local.private_endpoints

  location  = each.value.location
  name      = each.value.name
  parent_id = var.private_link.parent_id
  type      = var.resource_types.network_private_endpoints
  body = {
    properties = {
      subnet = { id = each.value.subnet_resource_id }
      privateLinkServiceConnections = [{
        name = each.value.name
        properties = {
          privateLinkServiceId = azapi_resource.private_link[0].id
          groupIds             = ["workspace"]
        }
      }]
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints) > 0 ? var.ignore_body_changes.network_private_endpoints : null
  replace_triggers_refs  = ["properties.subnet.id", "properties.privateLinkServiceConnections"]
  response_export_values = ["properties.customDnsConfigs", "properties.networkInterfaces", "properties.privateLinkServiceConnections"]
  retry                  = var.retry
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "private_dns_zone_group" {
  for_each = { for key, endpoint in local.private_endpoints : key => endpoint if endpoint.private_dns_zone_resource_id != null }

  name      = "default"
  parent_id = azapi_resource.private_endpoint[each.key].id
  type      = var.resource_types.network_private_endpoints_private_dns_zone_groups
  body = {
    properties = {
      privateDnsZoneConfigs = [{
        name       = "fabric"
        properties = { privateDnsZoneId = each.value.private_dns_zone_resource_id }
      }]
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups) > 0 ? var.ignore_body_changes.network_private_endpoints_private_dns_zone_groups : null
  response_export_values = ["properties.privateDnsZoneConfigs"]
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
