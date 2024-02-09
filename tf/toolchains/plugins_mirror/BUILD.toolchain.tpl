load("@rules_tf//tf:toolchains.bzl", "plugins_mirror_toolchain")

package(default_visibility = ["//visibility:public"])

plugins_mirror_toolchain(
   name = "{name}_toolchain_impl",
   versions = {
      {versions}
   },
)

toolchain(
  name = "{name}_toolchain",
  toolchain = ":{name}_toolchain_impl",
  toolchain_type = "@rules_tf//:tf_plugins_mirror_toolchain_type",
  visibility = ["//visibility:public"],
)
