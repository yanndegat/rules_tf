package(default_visibility = ["//visibility:public"])

exports_files(["config.hcl", "wrapper.sh", "tflint_plugins"])

alias(
    name = "runtime",
    actual = "tflint/tflint",
    visibility = ["//visibility:public"]
)
