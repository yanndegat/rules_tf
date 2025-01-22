package(default_visibility = ["//visibility:public"])

alias(
    name = "runtime",
    actual = "terraform/terraform",
    visibility = ["//visibility:public"]
)

exports_files(
     ["mirror"],
)
