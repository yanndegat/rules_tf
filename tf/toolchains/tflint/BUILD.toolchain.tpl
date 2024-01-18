load("@rules_tf//tf:toolchains.bzl", "tflint_toolchain", "platforms")

package(default_visibility = ["//visibility:public"])

exports_files(["config.hcl", "wrapper.sh"])

filegroup(
    name = "runtime",
    srcs = ["tflint/tflint"],
    visibility = ["//visibility:public"]
)

tflint_toolchain(
   name = "toolchain_impl",
   tflint = ":runtime",
   config = ":config.hcl",
   wrapper = ":wrapper.sh",
)

toolchain(
  name = "toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":toolchain_impl",
  toolchain_type = "@rules_tf//:tflint_toolchain_type",
  visibility = ["//visibility:public"],
)
