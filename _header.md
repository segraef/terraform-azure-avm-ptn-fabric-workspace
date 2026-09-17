# Fabric Workspace Pattern Module

Create a Fabric workspace on an existing capacity, with workspace identity and role assignments. Optionally add Private Link, outbound access protection (OAP), managed private endpoints, and a Git connection.

**Status:** Public source code, not yet an approved Azure Verified Module or a production-validated release.

## Get started

Start with the [single workspace example](examples/default) or use [multiple workspaces](examples/multiple_workspaces) to share a capacity through `for_each`. The examples include provider configuration.

This module provisions the workspace, not the capacity or its contents. Create capacity separately, then pass its **Fabric capacity GUID**, not its Azure Resource Manager (ARM) ID.

## Prerequisites

- Permission to create and administer Fabric workspaces and assign them to the capacity.
- For Private Link and OAP: a purchased F capacity, supported regions and item types, and the required tenant settings.
- For Private Link: Azure networking permissions, existing resource groups, subnets, DNS zones, and working DNS forwarding.

You manage shared networking, gateways, tenant settings, remote state, and access to data sources separately. Workspace identity is Fabric-managed, not an attachable Azure user-assigned identity; it still needs destination permissions.

## Provider boundary

The module uses `microsoft/fabric` for workspace features and `Azure/azapi` for Azure networking. Configure authentication and both Fabric provider bindings in your calling configuration:

| Provider | Routing |
|---|---|
| Default Fabric provider | Use workspace-specific routing after private access is enabled. |
| `fabric.global` | Keep `use_workspace_private_link_endpoint = false` for communication-policy operations. |

## Private networking lifecycle

1. Create an empty workspace with `private_link` configured and public inbound access enabled. Attach your existing DNS zones.
2. Verify private DNS, TCP connectivity, and authenticated access from the runner and intended clients. Reserve at least ten IP addresses per workspace endpoint and preserve every generated DNS mapping.
3. Switch the default Fabric provider to workspace-specific routing, set `private_access_verified = true`, and set `public_network_access_enabled = false`. Keep `fabric.global` reachable.

**Keep the runner connected.** Terraform needs private access for refresh, updates, and destruction. Before removing Private Link from a locked workspace, restore permitted access and runner routing. The verification flag does not test connectivity; policy changes can take time to propagate. Do not load sensitive data during bootstrap.

### Outbound access

Inbound Private Link does not provide outbound connectivity. OAP is off when its input is `null`; configuring it enables default-deny access. Exceptions apply afterward, so enable protection before running production workloads to avoid temporary disruption. Git needs explicit OAP consent.

Managed private endpoints require supported workloads and target-owner approval. Creating an endpoint does not grant data access.

## Git and release ownership

Supply the ID of an existing Fabric configured connection accessible to the deploying principal, never credentials. Initialization can synchronize content but does not overwrite conflicts automatically.

Use release tooling for ongoing content updates, tests, approvals, and promotions. Give each resource or property one owner to avoid competing changes. Native Fabric deployment pipelines are not supported with workspace inbound access protection, even with a private runner.

## Validation

The initial candidate passed provider-mocked unit tests and managed lint. Full AVM validation and live deployment, idempotency, policy-plan, and teardown checks remain outstanding. Mocked tests do not verify cloud behavior.

For contributors, use PowerShell 7.4+ with `Avm.Authoring`: run `avm test unit` and `avm pre-commit`, commit the reviewed changes, then run `avm pr-check`. Validate Terraform through an example that supplies `fabric.global`.

The initial pre-commit run with Avm.Authoring 0.13.0 and MAPOTF 0.1.12 failed on provider aliases; see [Azure/mapotf#128](https://github.com/Azure/mapotf/pull/128).

## References

- [Workspace Private Link setup](https://learn.microsoft.com/fabric/security/security-workspace-level-private-links-set-up)
- [Workspace outbound access protection](https://learn.microsoft.com/fabric/security/workspace-outbound-access-protection-overview)
- [Workspace identity](https://learn.microsoft.com/fabric/security/workspace-identity)
- [CI/CD network security](https://learn.microsoft.com/fabric/cicd/cicd-security)
