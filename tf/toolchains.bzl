load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "register_tofu_toolchain")
load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "register_terraform_toolchain")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "register_tfdoc_toolchain")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "register_tflint_toolchain")

def register_toolchains():
    register_terraform_toolchain(visibility = ["//visibility:public"])
    register_tfdoc_toolchain(visibility = ["//visibility:public"])
    register_tflint_toolchain(visibility = ["//visibility:public"])
    register_tofu_toolchain(visibility = ["//visibility:public"])
