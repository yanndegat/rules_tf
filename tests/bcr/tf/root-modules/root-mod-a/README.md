<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.5.7 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amodule"></a> [amodule](#module\_amodule) | ../../modules/mod-a | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.a_random_string](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input_var"></a> [input\_var](#input\_input\_var) | an input var | `string` | `"foobar"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mod_outputs"></a> [mod\_outputs](#output\_mod\_outputs) | output module's outputs |
| <a name="output_my_output"></a> [my\_output](#output\_my\_output) | output the input var |
<!-- END_TF_DOCS -->