config {
    format = "compact"
    module = true
    force = false
    disabled_by_default = false
}

# Default rules:
# # terraform_deprecated_interpolation
# # terraform_module_pinned_source
# # terraform_module_version
# # terraform_workspace_remote
#
#rule "terraform_comment_syntax" {
#  enabled = true
#

rule "terraform_deprecated_index" {
    enabled = true
}

rule "terraform_documented_outputs" {
    enabled = true
}

rule "terraform_documented_variables" {
    enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
  force   = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
# tf lint support for provider functions is implemented but not released
# by the time of this patch (tflint v0.9.1). Once released, please enable
# cf https://github.com/terraform-linters/tflint-ruleset-terraform/pull/214
# enabled = true
  enabled = false
}
