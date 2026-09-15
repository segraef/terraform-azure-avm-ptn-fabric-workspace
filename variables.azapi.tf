variable "resource_types" {
  type = object({
    fabric_private_link_services_for_fabric           = optional(string, "Microsoft.Fabric/privateLinkServicesForFabric@2024-06-01")
    network_private_endpoints                         = optional(string, "Microsoft.Network/privateEndpoints@2024-05-01")
    network_private_endpoints_private_dns_zone_groups = optional(string, "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01")
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
AzAPI resource types and API versions owned by this pattern.
- `fabric_private_link_services_for_fabric` - Workspace inbound Private Link service.
- `network_private_endpoints` - Azure private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Endpoint DNS zone groups.
DESCRIPTION
}

variable "ignore_body_changes" {
  type = object({
    fabric_private_link_services_for_fabric           = optional(list(string), [])
    network_private_endpoints                         = optional(list(string), [])
    network_private_endpoints_private_dns_zone_groups = optional(list(string), [])
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Body-relative dot paths ignored by AzAPI. Ignored configuration is not sent to Azure; changes take effect only after apply. Non-empty lists require Terraform 1.11 or later. List indices are not supported.
- `fabric_private_link_services_for_fabric` - Paths on the Fabric Private Link service.
- `network_private_endpoints` - Paths on Azure private endpoints.
- `network_private_endpoints_private_dns_zone_groups` - Paths on endpoint DNS zone groups.
DESCRIPTION
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Optional retry configuration for every AzAPI resource. Null uses provider defaults.
- `error_message_regex` - Error patterns triggering retry; required when configuring retry.
- `interval_seconds` - Initial retry interval in seconds.
- `max_interval_seconds` - Maximum retry interval in seconds.
DESCRIPTION

  validation {
    condition     = var.retry == null ? true : try(length(var.retry.error_message_regex) > 0, false)
    error_message = "retry must include at least one error_message_regex."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Optional operation timeouts for every AzAPI resource. Null uses provider defaults. Values are Go duration strings such as 30m.
- `create` - Create timeout.
- `read` - Read timeout.
- `update` - Update timeout.
- `delete` - Delete timeout.
DESCRIPTION
}
