load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", _terraform_toolchain = "terraform_toolchain")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", _tofu_toolchain = "tofu_toolchain")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", _tfdoc_toolchain = "tfdoc_toolchain")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", _tflint_toolchain = "tflint_toolchain")

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


terraform_toolchain = _terraform_toolchain
tofu_toolchain = _tofu_toolchain
tfdoc_toolchain = _tfdoc_toolchain
tflint_toolchain = _tflint_toolchain
