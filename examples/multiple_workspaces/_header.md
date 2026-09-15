# Multiple Workspaces

Uses module `for_each` to create separate development, test, and production workspaces on an existing capacity. Override the generic names for a real deployment and provide an existing capacity GUID. Authentication and tenant prerequisites match the default example.

Shared capacity, domain-wide assignments, DNS, and release orchestration belong to this consuming layer rather than each workspace module instance. This example does not create deployment pipelines or promote content.
