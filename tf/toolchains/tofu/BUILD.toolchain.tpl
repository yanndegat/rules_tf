package(default_visibility = ["//visibility:public"])

filegroup(
    name = "runtime",
    srcs = ["tofu/tofu"],
    visibility = ["//visibility:public"]
)
