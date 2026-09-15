# RMFR7 applies to resource modules, not this Fabric/networking pattern.
# Workspace GUID and optional ARM networking IDs have explicit separate outputs.
# Scope: root only. Remove if the rule gains module-class detection.
# https://azure.github.io/Azure-Verified-Modules/spec/RMFR7
rule "avm_output_resource_id_required" {
  enabled = false
}
