load("@rules_tf//tf/toolchains:tf_toolchain.bzl", _tf_toolchain = "tf_toolchain")
load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", _terraform_declare_toolchain_chunk = "DECLARE_TOOLCHAIN_CHUNK")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", _tofu_declare_toolchain_chunk = "DECLARE_TOOLCHAIN_CHUNK")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", _tfdoc_toolchain = "tfdoc_toolchain")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", _tfdoc_declare_toolchain_chunk = "DECLARE_TOOLCHAIN_CHUNK")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", _tflint_toolchain = "tflint_toolchain")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", _tflint_declare_toolchain_chunk = "DECLARE_TOOLCHAIN_CHUNK")

platforms = {
    "linux_amd64": {
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64":{
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64":{
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64":{
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}


def detect_host_platform(ctx):
    os = ctx.os.name
    if os == "mac os x":
        os = "darwin"
    elif os.startswith("windows"):
        os = "windows"

    arch = ctx.os.arch
    if arch == "aarch64":
        arch = "arm64"
    elif arch == "x86_64":
        arch = "amd64"

    return os, arch


tf_toolchain = _tf_toolchain
tfdoc_toolchain = _tfdoc_toolchain
tflint_toolchain = _tflint_toolchain

def _tf_toolchains_impl(ctx):
    content = """
load("@rules_tf//tf:toolchains.bzl", "platforms")
load("@rules_tf//tf:toolchains.bzl", "tfdoc_toolchain")
load("@rules_tf//tf:toolchains.bzl", "tflint_toolchain")
load("@rules_tf//tf:toolchains.bzl", "tf_toolchain")

package(default_visibility = ["//visibility:public"])
    """

    for repo in ctx.attr.tflint_repos:
        chunk = _tflint_declare_toolchain_chunk.format(
            toolchain_repo = repo,
            os = ctx.attr.os,
            arch = ctx.attr.arch,
        )
        content += chunk

    for repo in ctx.attr.tfdoc_repos:
        chunk = _tfdoc_declare_toolchain_chunk.format(
            toolchain_repo = repo,
            os = ctx.attr.os,
            arch = ctx.attr.arch,
        )
        content += chunk

    for repo in ctx.attr.terraform_repos:
        chunk = _terraform_declare_toolchain_chunk.format(
            toolchain_repo = repo,
            os = ctx.attr.os,
            arch = ctx.attr.arch,
        )
        content += chunk

    for repo in ctx.attr.tofu_repos:
        chunk = _tofu_declare_toolchain_chunk.format(
            toolchain_repo = repo,
            os = ctx.attr.os,
            arch = ctx.attr.arch,
        )
        content += chunk

    ctx.file( "BUILD.bazel", content, executable = False )

tf_toolchains = repository_rule(
    implementation = _tf_toolchains_impl,
    attrs = {
        "tflint_repos": attr.string_list(mandatory = True),
        "tfdoc_repos": attr.string_list(mandatory = True),
        "terraform_repos": attr.string_list(mandatory = True),
        "tofu_repos": attr.string_list(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
    },
)
