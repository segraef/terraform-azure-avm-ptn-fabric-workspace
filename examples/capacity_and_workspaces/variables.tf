variable "capacity_administration_members" {
  type        = set(string)
  description = "Existing Entra user UPNs or service principal object IDs that administer the capacity. Include the Fabric provider principal so it can discover and assign the capacity. Groups are not supported."
  nullable    = false
}

variable "capacity_name" {
  type        = string
  description = "Lowercase alphanumeric capacity name, unique among capacities visible to the Fabric provider principal."
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region with sufficient approved Fabric capacity-unit quota."
  nullable    = false
}

variable "resource_group_id" {
  type        = string
  description = "ARM resource ID of the existing resource group in which to create the capacity."
  nullable    = false
}

variable "capacity_sku_name" {
  type        = string
  default     = "F2"
  description = "Purchased Fabric F SKU. F2 is an illustrative starting size, not a production sizing recommendation."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Enable AVM telemetry for the capacity and workspaces."
  nullable    = false
}

variable "workspaces" {
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {
    development = { name = "example-development" }
    test        = { name = "example-test" }
  }
  description = "Independent workspaces sharing the new capacity, keyed by stable names."
  nullable    = false
}
