# Default Workspace

Creates one workspace on an existing capacity with a workspace identity and no outbound restrictions. Supply `capacity_id` through an uncommitted variable file or `TF_VAR_capacity_id`. Authentication uses the providers' supported environment variables or Azure CLI; no credentials are stored in this example.

The default display name is illustrative. Choose a unique `name` for real testing. The example is deployable only with the required Fabric tenant settings, capacity permissions, and Azure/Fabric authentication. This example does not provision capacity or run data workloads.
