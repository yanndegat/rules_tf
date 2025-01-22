package(default_visibility = ["//visibility:public"])

exports_files(["config.yaml"])

alias(
    name = "runtime",
    actual = "terraform-docs/terraform-docs",
    visibility = ["//visibility:public"],
)
