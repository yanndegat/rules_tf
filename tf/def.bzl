load("@rules_pkg//pkg:pkg.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files")
load("@rules_tf//tf/rules:tf-gen-doc.bzl", _tf_gen_doc = "tf_gen_doc" )
load("@rules_tf//tf/rules:tf-gen-versions.bzl", "tf_gen_versions")
load("@rules_tf//tf/rules:tf-providers-versions.bzl", _tf_providers_versions = "tf_providers_versions")
load("@rules_tf//tf/rules:tf-lint.bzl", "tf_lint_test")
load("@rules_tf//tf/rules:tf-module.bzl", _tf_module = "tf_module", "tf_module_deps", "tf_artifact", "tf_validate_test", _tf_format = "tf_format", "tf_format_test")

BZL_FILES = [
    "**/*.bazel",
    "**/WORKSPACE*",
    "**/BUILD",
]

def tf_module(name,
              data = [],
              size="small",
              providers = [],
              providers_versions = None,
              tflint_config = None,
              deps = [],
              visibility= ["//visibility:public"]):

    tf_gen_versions(
        name = "gen-tf-versions",
        providers = providers,
        providers_versions  = providers_versions,
        visibility = visibility,
    )

    pkg_files(
        name = "srcs",
        srcs = native.glob(["**/*"], exclude=BZL_FILES) + data,
        strip_prefix = "", # this is important to preserve directory structure
        prefix = native.package_name(),
    )

    _tf_module(
        name = "module",
        deps = deps,
        srcs = ":srcs",
    )

    tf_module_deps(
        name = "deps",
        mod = ":module",
    )

    tf_format_test(
        name = "format",
        size = size,
        module = ":module",
    )

    tf_lint_test(
        name = "lint",
        module = ":module",
        config = tflint_config,
        size = size,
    )

    tf_validate_test(
        name = "validate",
        module = ":module",
        size = size,
    )

    pkg_tar(
        name = "tgz",
        srcs = [ ":module", ":deps"],
        out = "{}.tar.gz".format(name),
        extension = "tar.gz",
        strip_prefix = ".", # this is important to preserve directory structure
    )

    tf_artifact(
        name = name,
        module = ":module",
        package = ":tgz",
        tags = ["no-sandbox"],
        visibility = ["//visibility:public"],
    )


def tf_format(name, modules):
    _tf_format(
        name = name,
        modules = modules,
        visibility = ["//visibility:public"],
    )

def tf_gen_doc(name, modules, config = None):
    _tf_gen_doc(
        name = name,
        modules = modules,
        config = config,
        visibility = ["//visibility:public"],
    )

def tf_providers_versions(name, tf_version = "", versions = {}):
    _tf_providers_versions(
        name = name,
        versions = versions,
        tf_version = tf_version,
        visibility = ["//visibility:public"],
    )
