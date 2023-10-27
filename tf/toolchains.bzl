load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "register_tofu_toolchain")
load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "register_terraform_toolchain")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "register_tfdoc_toolchain")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "register_tflint_toolchain")

def register_toolchains():
    register_terraform_toolchain(version = "1.5.7", visibility = ["//visibility:public"])
    register_tfdoc_toolchain(version = "0.16.0", visibility = ["//visibility:public"])
    register_tflint_toolchain(version = "0.48.0", visibility = ["//visibility:public"])
    register_tofu_toolchain(version = "1.6.0-valpha3", visibility = ["//visibility:public"])
