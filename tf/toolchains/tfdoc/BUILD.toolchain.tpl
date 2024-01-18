load("@rules_tf//tf:toolchains.bzl", "tfdoc_toolchain", "platforms")

package(default_visibility = ["//visibility:public"])

exports_files(["config.yaml"])

filegroup(
    name = "runtime",
    srcs = ["terraform-docs/terraform-docs"],
    visibility = ["//visibility:public"]
)

tfdoc_toolchain(
   name = "toolchain_impl",
   tfdoc = ":runtime",
   config = ":config.yaml",
)

toolchain(
  name = "toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":toolchain_impl",
  toolchain_type = "@rules_tf//:tfdoc_toolchain_type",
  visibility = ["//visibility:public"],
)
