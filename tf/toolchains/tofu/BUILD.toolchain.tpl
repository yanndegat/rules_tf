load("@rules_tf//tf:toolchains.bzl", "tofu_toolchain", "platforms")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "runtime",
    srcs = ["tofu/tofu"],
    visibility = ["//visibility:public"]
)

tofu_toolchain(
   name = "toolchain_impl",
   tf = ":runtime",
)

toolchain(
  name = "toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":toolchain_impl",
  toolchain_type = "@rules_tf//:tf_toolchain_type",
  visibility = ["//visibility:public"],
)
