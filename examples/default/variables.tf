variable "capacity_id" {
  type        = string
  description = "GUID of an existing Fabric capacity accessible to the deployment identity."
  nullable    = false
}

variable "name" {
  type        = string
  default     = "example-workspace"
  description = "Unique workspace display name for this example."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Enable AVM deployment telemetry."
  nullable    = false
}
