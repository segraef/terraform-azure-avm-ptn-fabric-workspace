variable "private_access_verified" {
  type        = bool
  default     = false
  description = "Consumer acknowledgement that private endpoint connectivity, DNS, and Fabric provider private routing have been verified. Required before denying public inbound access; this is not an automated connectivity test."
  nullable    = false
}

variable "private_link" {
  type = object({
    name      = string
    parent_id = string
    endpoints = optional(map(object({
      name                         = string
      location                     = string
      subnet_resource_id           = string
      private_dns_zone_resource_id = optional(string)
    })), {})
  })
  default     = null
  description = <<DESCRIPTION
Optional inbound workspace Private Link service and endpoints. Null creates no inbound networking.
- `name` - Azure name of the Fabric Private Link service, independent of the workspace display name.
- `parent_id` - Existing resource group ARM ID for the service and endpoints.
- `endpoints` - Private endpoints keyed by stable caller-chosen names.
- `endpoints.name` - Azure private endpoint name.
- `endpoints.location` - Region of the endpoint subnet.
- `endpoints.subnet_resource_id` - Existing subnet ARM ID. Reserve at least ten free IP addresses per workspace endpoint.
- `endpoints.private_dns_zone_resource_id` - Existing privatelink.fabric.microsoft.com zone ARM ID; omit if DNS zone groups are managed externally.
The consumer owns shared DNS zones, VNet links, forwarding, routing, and subnet policies.
DESCRIPTION

  validation {
    condition     = var.private_link == null ? true : can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.private_link.parent_id))
    error_message = "private_link.parent_id must be an existing resource group ARM ID."
  }
  validation {
    condition = var.private_link == null ? true : alltrue([for endpoint in values(var.private_link.endpoints) :
      can(provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks/subnets", endpoint.subnet_resource_id))
    ])
    error_message = "Each private endpoint subnet_resource_id must be a subnet ARM ID."
  }
  validation {
    condition = var.private_link == null ? true : alltrue([for endpoint in values(var.private_link.endpoints) :
      endpoint.private_dns_zone_resource_id == null ? true :
      try(lower(provider::azapi::parse_resource_id("Microsoft.Network/privateDnsZones", endpoint.private_dns_zone_resource_id).name) == "privatelink.fabric.microsoft.com", false)
    ])
    error_message = "Each private DNS zone must be the ARM ID of a privatelink.fabric.microsoft.com zone."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Allow public inbound workspace access. Set false only after validating private routing, DNS, and the consumer's workspace-specific Fabric provider configuration."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Azure tags applied to the Private Link service and private endpoints, not Fabric workspace tags."
}
