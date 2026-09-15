variable "capacity_id" {
  type        = string
  nullable    = false
  description = "Fabric capacity GUID, not the capacity ARM resource ID. Private networking and OAP require a purchased F capacity."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.capacity_id))
    error_message = "capacity_id must be a Fabric capacity GUID."
  }
}

variable "name" {
  type        = string
  nullable    = false
  description = "Display name of the Fabric workspace."

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 256 && lower(var.name) != "admin monitoring"
    error_message = "name must contain 1 to 256 characters and must not be the reserved name Admin monitoring."
  }
}

variable "description" {
  type        = string
  default     = ""
  nullable    = false
  description = "Description of the Fabric workspace."

  validation {
    condition     = length(var.description) <= 4000
    error_message = "description must not exceed 4000 characters."
  }
}

variable "workspace_identity_enabled" {
  type        = bool
  default     = true
  nullable    = false
  description = "Create a Fabric-managed workspace identity. This is not an Azure user-assigned identity; destination permissions and connection authentication are configured separately."
}

variable "workspace_role_assignments" {
  type = map(object({
    principal_id   = string
    principal_type = string
    role           = string
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Fabric workspace roles keyed by caller-chosen stable names, not Azure RBAC assignments.
- `principal_id` - Microsoft Entra principal object GUID.
- `principal_type` - User, Group, ServicePrincipal, or ServicePrincipalProfile.
- `role` - Admin, Member, Contributor, or Viewer.
DESCRIPTION

  validation {
    condition = alltrue([for assignment in values(var.workspace_role_assignments) :
      contains(["User", "Group", "ServicePrincipal", "ServicePrincipalProfile"], assignment.principal_type) &&
      contains(["Admin", "Member", "Contributor", "Viewer"], assignment.role) &&
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_id))
    ])
    error_message = "Workspace role assignments require a principal GUID, a supported principal type, and a supported workspace role."
  }
}

variable "outbound_access_protection" {
  type = object({
    allowed_gateway_ids = optional(set(string), [])
    allow_git           = optional(bool, false)
    cloud_connection_rules = optional(map(object({
      allowed_hostname_patterns = optional(set(string), [])
      allowed_workspace_ids     = optional(set(string), [])
    })), {})
  })
  default     = null
  description = <<DESCRIPTION
Null leaves OAP disabled. A non-null object enables default-deny outbound access.
- `allowed_gateway_ids` - Gateways explicitly allowed by GUID.
- `allow_git` - Explicit consent for outbound Git integration; defaults to false.
- `cloud_connection_rules` - Rules keyed by Fabric API connection type, not display name.
- `cloud_connection_rules.allowed_hostname_patterns` - Allowed destinations for connection types supporting endpoint filtering.
- `cloud_connection_rules.allowed_workspace_ids` - Allowed Fabric workspace GUIDs for types supporting workspace filtering.
Rules do not create connections, grant permissions, or provide private routing. Unsupported items prevent enabling OAP.
DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}
