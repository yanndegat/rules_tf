package(default_visibility = ["//visibility:public"])

exports_files(["config.hcl", "wrapper.sh"])

filegroup(
    name = "runtime_{os}_{arch}",
    srcs = ["tflint/tflint"],
    visibility = ["//visibility:public"]
)
