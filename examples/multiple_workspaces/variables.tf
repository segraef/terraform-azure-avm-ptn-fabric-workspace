variable "capacity_id" {
  type        = string
  description = "GUID of an existing Fabric capacity shared by this example's workspaces."
  nullable    = false
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
  description = "Independent workspaces keyed by stable names. These generic names are illustrative, not a prescribed enterprise workspace design."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Enable AVM deployment telemetry for every workspace."
  nullable    = false
}
