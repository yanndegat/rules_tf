package(default_visibility = ["//visibility:public"])

alias(
    name = "runtime",
    actual = "tofu/tofu",
    visibility = ["//visibility:public"]
)

exports_files(
     ["mirror"],
)
