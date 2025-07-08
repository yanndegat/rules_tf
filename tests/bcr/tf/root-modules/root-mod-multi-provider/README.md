# Root Module - Multi-Provider Example

This root module demonstrates how to use the `multi_provider` nested module with provider configuration aliases.

## Architecture

This example shows:
1. **Root Module**: Defines concrete provider configurations (`random.primary` and `random.secondary`)
2. **Nested Module**: Uses the multi_provider module which declares `configuration_aliases` 
3. **Provider Mapping**: Maps the root module's provider instances to the nested module's aliases

## Key Features

- **Provider Aliases**: Demonstrates how to use the same provider type with different configurations
- **Dictionary Format**: Shows the new dictionary format for providers with `configuration_aliases`
- **Proper Validation**: The root module can be validated (unlike the nested module with aliases)

## Usage

The nested module (`//tf/modules/multi_provider`) uses the dictionary format:

```python
providers = {
    "random": {
        "configuration_aliases": ["random.primary", "random.secondary"]
    }
}
```

While this root module uses the standard string list format and provides concrete provider configurations:

```python
providers = [
    "random",
]
```

## Files Generated

- `versions.tf.json`: Contains proper Terraform provider requirements with configuration aliases
- Both modules generate their respective versions files with correct JSON structure