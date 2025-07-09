<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, <= 1.10 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random.primary"></a> [random.primary](#provider\_random.primary) | 3.3.2 |
| <a name="provider_random.secondary"></a> [random.secondary](#provider\_random.secondary) | 3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.primary](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |
| [random_string.secondary](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_length"></a> [length](#input\_length) | Length of the random string | `number` | `8` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_value"></a> [primary\_value](#output\_primary\_value) | The random string from primary provider |
| <a name="output_secondary_value"></a> [secondary\_value](#output\_secondary\_value) | The random string from secondary provider |
<!-- END_TF_DOCS -->