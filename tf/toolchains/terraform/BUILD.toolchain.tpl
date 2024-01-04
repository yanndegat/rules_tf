package(default_visibility = ["//visibility:public"])

filegroup(
    name = "runtime_{os}_{arch}",
    srcs = ["terraform/terraform"],
    visibility = ["//visibility:public"]
)
