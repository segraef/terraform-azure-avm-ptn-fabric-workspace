variable "capacity_id" {
  type        = string
  nullable    = false
  description = "GUID of an existing Fabric capacity shared by this example's workspaces."
}

variable "workspaces" {
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {
    dev  = { name = "example-development" }
    test = { name = "example-test" }
    prod = { name = "example-production" }
  }
  nullable    = false
  description = "Independent workspaces keyed by stable names. These generic names are illustrative, not a prescribed enterprise workspace design."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  nullable    = false
  description = "Enable AVM deployment telemetry for every workspace."
}
