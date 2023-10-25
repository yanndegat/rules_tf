package(default_visibility = ["//visibility:public"])

exports_files(["config.yaml"])

filegroup(
    name = "runtime",
    srcs = ["terraform-docs/terraform-docs"],
    visibility = ["//visibility:public"]
)
