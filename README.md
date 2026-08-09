# Tf Rules

The Tf rules are useful to validate, lint and format terraform code.

They can typically be used in a terraform monorepo of modules to lint, run validation tests, auto generate documentation and enforce the consistency of Tf and providers versions across all modules.

# Why "Tf" and not "Terraform"

Because now you can either use "tofu" or "terraform" binary.

## Getting Started

To import rules_tf in your project, you first need to add it to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_tf", version = "0.0.9")
# git_override(
#     module_name = "rules_tf",
#     remote      = "https://github.com/yanndegat/rules_tf",
#     commit      = "...",
# )

tf = use_extension("@rules_tf//tf:extensions.bzl", "tf_repositories", dev_dependency = True)
tf.download(
    version = "1.9.5",
    tflint_version = "0.53.0",
    tfdoc_version = "0.19.0",
    use_tofu = False,
    mirror = {
        "random" : "hashicorp/random:3.3.2",
        "null"   : "hashicorp/null:3.1.1",
    }
)

# Switch to tofu
# tf = use_extension("@rules_tf//tf:extensions.bzl", "tf_repositories")
# tf.download(
#    version = "1.6.0",
#    use_tofu = True,
#    mirror = {
#        "random" : "hashicorp/random:3.3.2",
#        "null"   : "hashicorp/null:3.1.1",
#    }
# )

use_repo(tf, "tf_toolchains")
register_toolchains(
    "@tf_toolchains//:all",
    dev_dependency = True,
)
```

### Restricted-egress, proxied or mirrored environments

By default, the toolchain fetches the CLI from its upstream release host and
populates the provider mirror by running `terraform providers mirror` (or
`tofu providers mirror`). That subprocess performs its **own** network I/O,
outside Bazel's downloader — so Bazel's own download controls (the downloader
config, URL rewrites, the repository cache and `.netrc` credentials) do not
apply to it. It can still be pointed elsewhere through the CLI's own mechanisms
(`HTTPS_PROXY`, or a `network_mirror` in `provider_installation`), but that is
configured separately from Bazel and is not always available.

Two optional attributes let you route those fetches through Bazel's downloader
instead, by naming a **pins file**: a JSON file stating, for each artifact and
each platform, where it is and what it must hash to. Omit them and behaviour is
exactly as before.

```python
tf.download(
    version = "1.9.5",
    mirror = {
        "random": "hashicorp/random:3.3.2",
        "null": "hashicorp/null:3.1.1",
    },

    # Fetch the CLI through Bazel instead of from the upstream release host.
    cli_pins = "//third_party:tf_cli_pins.json",

    # Fetch each provider through Bazel instead of running
    # `terraform providers mirror`.
    provider_pins = "//third_party:tf_provider_pins.json",
)
```

Both attributes use the same schema. Entries are keyed by artifact: `terraform`
or `tofu` for the CLI, and the provider's registry address for a provider.

```json
{
  "terraform": {
    "version": "1.9.5",
    "platforms": {
      "linux/amd64":  {"url": "https://...", "sha256": "..."},
      "darwin/arm64": {"url": "https://...", "sha256": "..."}
    }
  },
  "registry.terraform.io/hashicorp/null": {
    "version": "3.1.1",
    "platforms": {
      "linux/amd64":  {"url": "https://...", "sha256": "..."},
      "darwin/arm64": {"url": "https://...", "sha256": "..."}
    }
  }
}
```

Notes:

- The two attributes are independent, and each is all-or-nothing. If
  `provider_pins` is set, every provider in `mirror` must have an entry;
  there is no partial fallback to the subprocess, because it populates the
  whole mirror directory in one pass and reconciling that with a partial one is
  not worth the ambiguity.
- `mirror` is still required and still means the same thing: which providers
  and versions you want. A pins file only says where to fetch them from, so the
  two compose rather than compete.
- The rule owns the layout. You state where bytes come from; the rule decides
  where they go, which for providers is the exacting
  `<registry>/<namespace>/<type>/terraform-provider-<type>_<version>_<os>_<arch>.zip`
  path the engine expects. Note that the file name says `terraform-provider`
  for OpenTofu too; only the registry directory differs
  (`registry.opentofu.org` rather than `registry.terraform.io`).
- Provider addresses are lowercase. Registry display casing in `mirror`, e.g.
  `Azure/azapi`, is normalised for you.
- Because provider keys carry the engine's own registry host, one provider pins
  file serves one engine. A Terraform and an OpenTofu `tf.download` need
  separate files even for the same provider at the same version.
- URLs are per platform and per artifact, with nothing templated. That is
  deliberate: providers genuinely come from different hosts, with different
  path shapes and even different file-name conventions — HashiCorp's own live
  on `releases.hashicorp.com`, many third-party ones on GitHub releases, and
  private ones wherever their publisher put them. No placeholder set spans
  that, and stating each URL outright also makes a mix of public and private
  providers work with no extra switch.
- The `version` in each entry is cross-checked against `mirror`, so bumping a
  provider without regenerating the pins fails immediately and by name, rather
  than as a bare checksum mismatch part-way through a large download.
- Every lookup failure names both what was wanted and what the file offers,
  since these files are generated and the mismatch is usually between the file
  and the rest of the build.
- The CLI archive must be a zip with the `terraform` (or `tofu`) executable at
  its root, matching the format the default download path uses.
- The digest covers transport only. How an artifact was produced is trusted to
  whoever published it.
- Like the rest of the toolchain, the repository is built for the **host**
  platform Bazel is running on. Since one `MODULE.bazel` is shared by every
  machine on a project, pins are per platform, so a mixed Linux/macOS team can
  use a single declaration. Building on a platform with no pin is an error
  rather than a checksum mismatch.
- Because these go through Bazel's downloader, they honour the downloader
  config, the repository cache and `.netrc` like any other Bazel download. The
  flag is `--experimental_downloader_config` on every version this ruleset
  supports. That also means a pins file can
  hold **public** URLs and still be used against a private mirror: the rewrite
  happens before the request leaves the machine, so the same file works with
  and without the mirror, and contains no private hostnames.

### Using Tf rules

Once you've imported the rule set, you can then load the tf rules in your `BUILD` files with:

```python
load("@rules_tf//tf:def.bzl", "tf_providers_versions", "tf_module")

tf_providers_versions(
    name = "providers",
    tf_version = "1.2.3",
    providers = {
        "random" : "hashicorp/random:>=3.3",
        "null"   : "hashicorp/null:>=3.1",
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
    providers_versions = ":providers",
)
```

#### Provider Configuration Aliases

The `providers` parameter supports both string list format and dictionary format (for configuration aliases):

```python
# String list format (legacy)
tf_module(
    name = "simple-module",
    providers = [
        "random",
        "null",
    ],
    providers_versions = ":providers",
)

# Dictionary format (for provider aliases)
tf_module(
    name = "multi-provider-module",
    providers = {
        "random": {
            "configuration_aliases": ["random.primary", "random.secondary"]
        },
        "aws": {
            "configuration_aliases": ["aws.us_east_1", "aws.us_west_2"]
        }
    },
    providers_versions = ":providers",
)
```

The dictionary format allows you to specify `configuration_aliases` for providers that need multiple configurations, which is useful for multi-region deployments or when a module needs to work with multiple instances of the same provider.

#### Skipping Validation for Nested Modules

Modules that use provider configuration aliases are designed to be nested (called by other modules) and cannot be validated standalone because they don't have concrete provider configurations. For these modules, use `skip_validation = True`:

```python
# Nested module with provider aliases - cannot validate standalone
tf_module(
    name = "multi-region-module",
    providers = {
        "aws": {
            "configuration_aliases": ["aws.us_east_1", "aws.us_west_2"]
        }
    },
    providers_versions = "//tf:versions",
    skip_validation = True,  # Required for modules with configuration aliases
)

# Root module that uses the nested module - can validate
tf_module(
    name = "root-module",
    providers = ["aws"],
    deps = ["//tf/modules/multi-region-module"],
    providers_versions = "//tf:versions",
    # skip_validation = False (default) - root modules can be validated
)
```

This is necessary because Terraform cannot validate a module that declares configuration aliases without having concrete provider configurations passed to it from a parent module.

### Using prebuilt binaries

To ensure a consistent binary version across the team, you can create an alias to the prebuilt binaries:

```python
# Likewise for tofu, tfdoc, and tflint.
alias(
    name = "terraform",
    actual = "@tf_toolchains//:terraform",
)
```

And you can use `bazel run //:terraform` which uses the same version as configured in your `MODULE.bazel`.

## Using Tf Modules

1. Using custom tflint config file

```python
load("@rules_tf//tf:def.bzl", "tf_module")

filegroup(
    name = "tflint-custom-config",
    srcs = [
        "my-tflint-config.hcl",
    ],
)

tf_module(
    name = "mod-a",
    providers = [
        "random",
    ],
    ...
    tflint_config = ":tflint-custom-config"

)
```

1. Generating versions.tf.json files

Terraform linter by default requires that all providers used by a module
are versioned. It is possible to generate a versions.tf.json file by running
a dedicated target:

```python
load("@rules_tf//tf:def.bzl", "tf_providers_versions", "tf_module")

tf_providers_versions(
    name = "providers",
    tf_version = "1.2.3",
    providers = {
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

    providers_versions = ":providers",
)
```

``` bash
bazel run //path/to/root-mod-a:gen-tf-versions
```

or generate all files of a workspace:

``` bash
bazel cquery 'kind(tf_gen_versions, //...)' --output files | xargs -n1 bash
```

1. Generating terraform doc files

It is possible to generate a README.md file by running
a dedicated target for terraform modules:

```python
load("@rules_tf//tf:def.bzl", "tf_gen_doc")

tf_gen_doc(
    name = "tfgendoc",
    modules = ["//{}/{}".format(package_name(), m) for m in subpackages(include = ["**/*.tf"])],
)
```

and run the following command to generate docs for all sub packages.

``` bash
bazel run //path/to:tfgendoc
```

It is also possible to customize terraform docs config:

```python
load("@rules_tf//tf:def.bzl", "tf_gen_doc")

filegroup(
    name = "tfdoc-config",
    srcs = [
        "my-tfdoc-config.yaml",
    ],
)

tf_gen_doc(
    name   = "custom-tfgendoc",
    modules = ["//{}/{}".format(package_name(), m) for m in subpackages(include = ["**/*.tf"])],
    config = ":tfdoc-config",
)
```

1. Formatting terraform files

It is possible to format terraform files by running a dedicated target:

```python
load("@rules_tf//tf:def.bzl", "tf_format")


tf_format(
    name = "tffmt",
    modules = ["//{}/{}".format(package_name(), m) for m in subpackages(include = ["**/*.tf"])],
)
```

and run the following command to generate docs for all sub packages.

``` bash
bazel run //path/to:tffmt
```
