load("@rules_pkg//pkg:mappings.bzl", "pkg_files")
load("@rules_pkg//pkg:pkg.bzl", "pkg_tar")
load("@rules_tf//tf/rules:tf-gen-doc.bzl", _tf_gen_doc = "tf_gen_doc")
load("@rules_tf//tf/rules:tf-gen-versions.bzl", "tf_gen_versions")
load("@rules_tf//tf/rules:tf-lint.bzl", "tf_lint_test")
load("@rules_tf//tf/rules:tf-module.bzl", "tf_artifact", "tf_format_test", "tf_module_deps", "tf_validate_test", _tf_format = "tf_format", _tf_module = "tf_module")
load("@rules_tf//tf/rules:tf-providers-versions.bzl", _tf_providers_versions = "tf_providers_versions")

bzl_files = [
    "**/*.bzl",
    "**/*.bazel",
    "**/WORKSPACE*",
    "**/BUILD",
]

def tf_module(
        name,
        srcs = [],
        data = [],
        deps = [],
        size = "small",
        providers = [],
        providers_versions = None,
        tflint_config = None,
        tflint_extra_args = [],
        experiments = [],
        visibility = ["//visibility:public"],
        tags = [],
        skip_validation = False):
    """
    Generates various targets for building and validating a TF module.

    Args:
      name (string): A unique name for the resulting module (and used as a prefix for other rules).
      srcs (list of targets): TF source files that define the module. Defaults to all TF-related
        files in this package if not set.
      data (list of targets): Extraneous TF source files to combine with srcs. Defaults to empty.
      deps (list of targets): Other TF modules to use as dependencies.
      size: The standard test size attribute to apply to generated test targets. View
        https://bazel.build/reference/be/common-definitions#common-attributes-tests.
      providers (dictionary of strings to strings): TF providers to use. Keys are the provider
        aliases used in srcs, and values are actual provider names and versions (e.g. "random" :
        "hashicorp/random:3.3.2" defined an alias of "random" pointing to hashicorp/random:3.3.2).
      providers_versions (label): A target that defines the versions of providers to use. Values
        from this target override any versions specified by 'providers'.
      tflint_config (label): The configuration to use when linting the module.
      tflint_extra_args (list of strings): Extra args to pass to tflint when linting the module.
      experiments (list of strings): Experiments to include. View
        https://developer.hashicorp.com/terraform/language/block/terraform#experiments.
      visibility (list of labels): The visibility to apply to all generated rules. Defaults to
        public.
      tags (list of strings): A list of tags to apply to all generated rules. View
        https://bazel.build/reference/be/common-definitions#common-attributes.
      skip_validation (bool): Whether to skip generating the validation rules. Defaults to false.
    """

    # Handle both string list and dict formats for providers
    providers_list = []
    providers_dict_json = ""

    if type(providers) == type([]):
        # String list format (legacy)
        providers_list = providers
    elif type(providers) == type({}):
        # Dict format (new support for configuration aliases)
        providers_dict_json = json.encode(providers)
    else:
        fail("providers must be either a list of strings or a dict")

    tf_gen_versions(
        name = "%s_gen_tf_versions" % name,
        providers = providers_list,
        providers_dict_json = providers_dict_json,
        providers_versions = providers_versions,
        experiments = experiments,
        visibility = visibility,
        tags = tags,
    )

    composite_srcs = []
    if not srcs and not data:
        # While glob allows multiple file types in a single call, when allow_empty = False, there
        # must be at least one of each file type. That isn't necessarily the case here, so the glob
        # must be split into multiple calls with allow_empty = True, plus a final non-empty check on
        # the glob result.
        composite_srcs = (native.glob(["**/*.tf"], allow_empty = True) +
                          native.glob(["**/*.tf.json"], allow_empty = True) +
                          native.glob(["**/*.tfvars"], allow_empty = True) +
                          native.glob(["**/*.auto.tfvars"], allow_empty = True) +
                          native.glob(["**/*.tfstate"], allow_empty = True) +
                          native.glob(["**/*.tfstate.backup"], allow_empty = True) +
                          native.glob(["**/.terraform.lock.hcl"], allow_empty = True) +
                          native.glob(["**/*.tofu"], allow_empty = True) +
                          native.glob(["**/*.tofu.json"], allow_empty = True))
        if not composite_srcs:
            fail("No terraform/tofu files were found in this package and srcs was not set.")
    else:
        composite_srcs = srcs + data

    pkg_files(
        name = "%s_packaged_srcs" % name,
        srcs = composite_srcs,
        strip_prefix = "",  # this is important to preserve directory structure
        prefix = native.package_name(),
        tags = tags,
        visibility = visibility,
    )

    _tf_module(
        name = "%s_module" % name,
        deps = deps,
        srcs = ":%s_packaged_srcs" % name,
        tags = tags,
        visibility = visibility,
    )

    tf_module_deps(
        name = "%s_deps" % name,
        mod = ":%s_module" % name,
        tags = tags,
        visibility = visibility,
    )

    tf_format_test(
        name = "%s_format" % name,
        size = size,
        module = ":%s_module" % name,
        tags = tags,
        visibility = visibility,
    )

    tf_lint_test(
        name = "%s_lint" % name,
        module = ":%s_module" % name,
        config = tflint_config,
        extra_args = tflint_extra_args,
        size = size,
        tags = tags,
        visibility = visibility,
    )

    if not skip_validation:
        tf_validate_test(
            name = "%s_validate" % name,
            module = ":%s_module" % name,
            size = size,
            tags = tags,
            visibility = visibility,
        )

    pkg_tar(
        name = "%s_tgz" % name,
        srcs = [":%s_module" % name, ":%s_deps" % name],
        out = "{}.tar.gz".format(name),
        extension = "tar.gz",
        strip_prefix = ".",  # this is important to preserve directory structure
        tags = tags,
        visibility = visibility,
    )

    tf_artifact(
        name = name,
        module = ":%s_module" % name,
        package = ":%s_tgz" % name,
        visibility = visibility,
        tags = tags,
    )

def tf_format(name, modules, kwargs):
    _tf_format(
        name = name,
        modules = modules,
        **kwargs
    )

def tf_gen_doc(name, modules, config = None, **kwargs):
    _tf_gen_doc(
        name = name,
        modules = modules,
        config = config,
        **kwargs
    )

def tf_providers_versions(name, tf_version = "", providers = {}, tags = ["no-sandbox"], **kwargs):
    _tf_providers_versions(
        name = name,
        providers = providers,
        tf_version = tf_version,
        tags = tags,
        **kwargs
    )
