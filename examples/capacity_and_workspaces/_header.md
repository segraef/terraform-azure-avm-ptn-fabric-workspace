# Shared Capacity and Workspaces

Creates one paid Fabric capacity through `Azure/avm-res-fabric-capacity/azure` 0.1.0 and multiple workspaces through this pattern module. Capacity creation is owned by the consuming root, not repeated inside each workspace module. The existing-capacity examples remain unchanged.

Supply an existing resource-group ARM ID, a supported Azure region with approved Fabric CU quota, a capacity name, and existing capacity administrators. Authenticate the AzAPI and Fabric providers to the intended tenant. The deployment identity needs Azure capacity-creation permissions and Fabric workspace-creation permissions; include its service principal object ID (or user UPN) among the capacity administrators so the Fabric API can discover and assign the capacity. Tenant settings for the chosen authentication method must already be enabled.

The capacity AVM exports an ARM resource ID, but workspaces require a Fabric capacity GUID. After capacity creation, `fabric_capacity` looks up that GUID by name through the global Fabric endpoint and checks that the capacity is active. Use a name unique among capacities visible to the caller. Fabric API visibility can lag ARM creation; this example has not yet been live-tested for that propagation window.

The default F2 is illustrative, not production sizing guidance. Capacity incurs charges while active even without running workloads; OneLake storage and other services may have separate charges. Destroying this example deletes all its workspaces and its capacity. Do not attach independently managed workspaces to this demonstration capacity.

This example does not enable Private Link, outbound access protection, or Git. It demonstrates capacity composition only, not a production security baseline. For private workspaces, also configure the pattern's private-link inputs and follow the documented staged connectivity verification before lockdown.

Run `terraform init` and `terraform validate` for configuration checks. Run `terraform test -test-directory=tests/unit` from this example directory for mocked composition tests; telemetry is disabled. Run Avm.Authoring commands from the repository root, not an example directory. A real apply requires the inputs above and explicit deployment authorization.
