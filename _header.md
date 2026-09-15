# Fabric Workspace Pattern Module

Candidate Terraform pattern targeting Azure Verified Modules standards. This repository is not an approved or published Azure Verified Module. Production readiness requires live deployment, idempotency, security, and teardown verification in an authorized environment.

Manages one Fabric workspace, capacity assignment, workspace identity, workspace roles, optional inbound Private Link, opt-in outbound access protection (OAP), outbound managed private endpoints, and an optional Git connection. Call the module with `for_each` to provision multiple independently configured workspaces.

## Provider boundary

Fabric workspaces are managed through Fabric REST APIs, not Azure Resource Manager. The module uses `microsoft/fabric` for workspace features and `Azure/azapi` for Azure networking. TFFR3 permits the Microsoft Fabric provider in a pattern module. No AzureRM resources are authored here.

Supply both the default Fabric provider and `fabric.global`. The global alias must have `use_workspace_private_link_endpoint = false`: the workspace communication-policy API does not accept the workspace-specific endpoint in a workspace-only Private Link configuration. The normal provider must use workspace-specific routing after lockdown. Provider configuration and authentication belong to the consuming root.

## Prerequisites

Supply an existing Fabric capacity GUID, not its ARM ID. Private Link and OAP require a purchased F capacity, supported regions and item types, and the relevant tenant settings. The deployment principal needs Fabric workspace-creation and capacity-assignment permissions, workspace administration, and Azure networking permissions when creating Private Link resources.

The consumer owns capacity provisioning, resource groups, virtual networks, subnets, shared DNS zones and links, DNS forwarding, gateway infrastructure, destination permissions, tenant policy, and remote state. Fabric workspace identity is not an attachable Azure user-assigned identity. Configure supported connections to use it and grant least-privilege destination access separately.

## Private networking lifecycle

1. Create an empty workspace with `private_link` configured and public inbound access enabled. Existing DNS zones can be attached to each endpoint; the module does not create shared zones or hand-author A records.
2. From the deployment runner and intended clients, verify DNS, TCP connectivity, and authenticated access through the private path. Reserve at least ten IP addresses per workspace endpoint; Fabric currently allocates five. Preserve all service-generated endpoint mappings.
3. Configure the normal Fabric provider for workspace-specific Private Link routing, set `private_access_verified = true`, and set `public_network_access_enabled = false`. Keep the global alias reachable for communication-policy operations.

Do not load sensitive data during bootstrap. The acknowledgement variable is a deployment guard, not proof of connectivity. Access-policy changes can take time to propagate. Terraform must retain private connectivity for refresh, updates, and destruction. Do not remove Private Link configuration from a locked workspace in one operation: first restore permitted access and runner routing, then remove networking. The resource graph deletes endpoints and their Fabric Private Link service before deleting the workspace.

Inbound Private Link does not provide outbound access. OAP is disabled when its input is null and defaults to deny when configured. Exceptions are configured after OAP, which can temporarily block workloads during enablement. Enable protection before loading or running production workloads. Git requires explicit OAP consent. Outbound managed private endpoints require target-owner approval and supported workloads; endpoint creation does not grant data access.

## Git and release ownership

Git integration requires an existing Fabric configured connection accessible to the deploying principal. The module accepts its identifier, never credentials. Initialization can synchronize content; conflicts are not automatically overwritten. Ongoing Git updates, tests, approvals, and promotions belong to release tooling. Do not give Terraform and release tooling competing ownership of the same Fabric items.

Native Fabric deployment pipelines are not supported with workspace inbound access protection. A private runner does not remove this limitation. Domain-wide workspace assignments, tenant settings, and cross-workspace release pipelines belong in the consuming composition to avoid competing authoritative resources.

## Composition notes

No published Fabric workspace resource module exists, and TFFR3 does not permit the Fabric provider in resource modules. The published `Azure/avm-res-network-privateendpoint/azurerm` 0.2.0 requires AzureRM configuration and does not expose the AzAPI controls used here. This candidate directly authors the small networking surface with AzAPI pending an appropriate AVM dependency and AVM review of this composition choice.

The documented `Microsoft.Fabric/privateLinkServicesForFabric@2024-06-01` ARM type is not recognized by AzAPI 2.12.0's embedded schema. Local schema validation is disabled only for that resource; Azure still validates requests. All other networking resources retain schema validation. No missing-schema workaround is used to impersonate Fabric workspaces as ARM resources.

## Validation

Initial candidate status: provider-mocked unit tests and managed lint pass. Full AVM validation has not passed. Avm.Authoring 0.13.0 with MAPOTF 0.1.12 fails to evaluate the valid `fabric.global` provider alias during `avm pre-commit`; the upstream fix is tracked in [Azure/mapotf#128](https://github.com/Azure/mapotf/pull/128). Live deployment, idempotency, policy-plan, and teardown validation remain outstanding. This initial source publication is not a production release or AVM approval.

Use PowerShell 7.4 or later and `Avm.Authoring`: `avm test unit`, `avm pre-commit`, then commit the reviewed tree and run `avm pr-check`. Unit tests mock every provider and do not prove cloud API behavior. The module requires the `fabric.global` alias, so validate through the consumer examples rather than running standalone root `terraform validate` without provider bindings.

## References

- [Workspace Private Link setup](https://learn.microsoft.com/fabric/security/security-workspace-level-private-links-set-up)
- [Workspace outbound access protection](https://learn.microsoft.com/fabric/security/workspace-outbound-access-protection-overview)
- [Workspace identity](https://learn.microsoft.com/fabric/security/workspace-identity)
- [CI/CD network security](https://learn.microsoft.com/fabric/cicd/cicd-security)
- [AVM permitted providers](https://azure.github.io/Azure-Verified-Modules/spec/TFFR3)
