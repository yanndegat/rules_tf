package(default_visibility = ["//visibility:public"])

filegroup(
    name = "runtime",
    srcs = ["terraform/terraform"],
    visibility = ["//visibility:public"]
)
