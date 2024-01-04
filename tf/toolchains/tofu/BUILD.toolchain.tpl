package(default_visibility = ["//visibility:public"])

filegroup(
    name = "runtime_{os}_{arch}",
    srcs = ["tofu/tofu"],
    visibility = ["//visibility:public"]
)
