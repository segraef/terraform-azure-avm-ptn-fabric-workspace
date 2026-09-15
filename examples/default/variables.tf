variable "capacity_id" {
  type        = string
  nullable    = false
  description = "GUID of an existing Fabric capacity accessible to the deployment identity."
}

variable "name" {
  type        = string
  default     = "example-workspace"
  nullable    = false
  description = "Unique workspace display name for this example."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  nullable    = false
  description = "Enable AVM deployment telemetry."
}
