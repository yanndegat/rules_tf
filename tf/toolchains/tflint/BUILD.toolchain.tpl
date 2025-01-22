package(default_visibility = ["//visibility:public"])

exports_files(["config.hcl", "wrapper.sh"])

alias(
    name = "runtime",
    actual = "tflint/tflint",
    visibility = ["//visibility:public"]
)
