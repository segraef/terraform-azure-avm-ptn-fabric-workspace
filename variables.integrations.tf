variable "git" {
  type = object({
    connection_id           = string
    provider_type           = string
    repository_name         = string
    branch_name             = string
    directory_name          = optional(string, "/")
    owner_name              = optional(string)
    organization_name       = optional(string)
    project_name            = optional(string)
    initialization_strategy = optional(string, "PreferRemote")
  })
  default     = null
  description = <<DESCRIPTION
Optional Git connection and initial synchronization. Subsequent releases are orchestrated outside Terraform.
- `connection_id` - Existing Fabric configured connection GUID accessible to the deploying principal. No credentials are accepted here.
- `provider_type` - GitHub or AzureDevOps.
- `repository_name` - Repository name.
- `branch_name` - Existing branch to connect.
- `directory_name` - Repository directory beginning with /.
- `owner_name` - Required for GitHub; omit for AzureDevOps.
- `organization_name` - Required for AzureDevOps; omit for GitHub.
- `project_name` - Required for AzureDevOps; omit for GitHub.
- `initialization_strategy` - PreferRemote or PreferWorkspace. Defaults to PreferRemote. Changing Git provider details forces reconnection.
Initialization does not consent to overwriting conflicting items. Use empty workspaces or reconcile conflicts before connecting.
DESCRIPTION

  validation {
    condition = var.git == null ? true : (
      contains(["GitHub", "AzureDevOps"], var.git.provider_type) &&
      contains(["PreferRemote", "PreferWorkspace"], var.git.initialization_strategy) &&
      startswith(var.git.directory_name, "/") &&
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.git.connection_id))
    )
    error_message = "git requires a configured connection GUID, GitHub or AzureDevOps, a supported initialization strategy, and an absolute repository directory."
  }
  validation {
    condition = var.git == null ? true : (var.git.provider_type == "GitHub" ? (
      try(length(trimspace(var.git.owner_name)) > 0, false) && var.git.organization_name == null && var.git.project_name == null
      ) : (
      var.git.owner_name == null && try(length(trimspace(var.git.organization_name)) > 0, false) && try(length(trimspace(var.git.project_name)) > 0, false)
    ))
    error_message = "GitHub requires only owner_name; AzureDevOps requires organization_name and project_name instead."
  }
}

variable "managed_private_endpoints" {
  type = map(object({
    name                            = string
    target_private_link_resource_id = string
    target_subresource_type         = optional(string)
    request_message                 = optional(string, "Requested by the workspace administrator.")
  }))
  default     = {}
  description = <<DESCRIPTION
Outbound Fabric-managed private endpoints, keyed by stable caller-chosen names. These are separate from inbound Azure private endpoints.
- `name` - Endpoint name, at most 64 characters.
- `target_private_link_resource_id` - Target Azure resource ARM ID. Polymorphic across supported services, so no single resource-type validation applies.
- `target_subresource_type` - Target subresource such as blob, dfs, or namespace; omit for a Private Link Service without subresources.
- `request_message` - Approval request, at most 140 characters.
Target owners must approve the connection. Creation is not proof of approval, reachability, workload support, or destination authorization.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([for endpoint in values(var.managed_private_endpoints) :
      length(endpoint.name) > 0 && length(endpoint.name) <= 64 && length(endpoint.request_message) <= 140
    ])
    error_message = "Managed private endpoint names must contain 1 to 64 characters and request messages must not exceed 140 characters."
  }
}
