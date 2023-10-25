# Tf Rules

The Tf rules is useful to validate, lint and format terraform code.

## Getting Started

To import rules_tf in your project, you first need to add it to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_tf", version = "", repo_name = "rules_tf")
tf_toolchains = use_extension("@rules_tf//tf:toolchains.bzl", "tf_toolchains")
```

Once you've imported the rule set , you can then load the tf rules in your `BUILD` files with:

```python
load("@rules_tf//tf:def.bzl", "tf_providers_versions", "tf_module")

tf_providers_versions(
    name = "versions",
    tf_version = "1.2.3",
    versions = {
        "random" : "hashicorp/random:3.3.2",
        "null"   : "hashicorp/null:3.1.1",
    },
)

tf_module(
    name = "root-mod-a",
    providers = [
        "random",
    ],
    deps = [
        "//tf/modules/mod-a",
    ],
    
    providers_versions = ":versions",
)

```

## Using Tf Modules

This is the first stab at getting a more mature set of Tf rules for Bazel.
