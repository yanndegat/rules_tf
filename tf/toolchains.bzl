load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "tofu_toolchain")
load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_toolchain")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "tfdoc_toolchain")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "tflint_toolchain")
load("@rules_tf//tf:versions.bzl", "TERRAFORM_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TFDOC_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TFLINT_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TOFU_VERSIONS")

def register_toolchains():

    native.toolchain_type(
        name = "terraform_toolchain_type",
        visibility = ["//visibility:public"],
    )
    native.toolchain_type(
        name = "tflint_toolchain_type",
        visibility = ["//visibility:public"],
    )
    native.toolchain_type(
        name = "tfdoc_toolchain_type",
        visibility = ["//visibility:public"],
    )

    for version in TERRAFORM_VERSIONS:
        toolchain_name = "terraform_{}_toolchain".format(version)
        terraform_toolchain(
            name = "{}_impl".format(toolchain_name),
            tf = "@terraform_{}//:runtime_{}".format(version, version),
        )

        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = TERRAFORM_VERSIONS[version]["exec_compatible_with"],
            target_compatible_with = TERRAFORM_VERSIONS[version]["target_compatible_with"],
            toolchain = ":{}_impl".format(toolchain_name),
            toolchain_type = ":terraform_toolchain_type",
            visibility = ["//visibility:public"],
        )


    for version in TFLINT_VERSIONS:
        toolchain_name = "tflint_{}_toolchain".format(version)
        tflint_toolchain(
            name = "{}_impl".format(toolchain_name),
            tflint = "@tflint_{}//:runtime_{}".format(version, version),
            config = "@tflint_{}//:config.hcl".format(version),
            wrapper = "@tflint_{}//:wrapper.sh".format(version),
        )

        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = TFLINT_VERSIONS[version]["exec_compatible_with"],
            target_compatible_with = TFLINT_VERSIONS[version]["target_compatible_with"],
            toolchain = ":{}_impl".format(toolchain_name),
            toolchain_type = ":tflint_toolchain_type",
            visibility = ["//visibility:public"],
        )


    for version in TFDOC_VERSIONS:
        toolchain_name = "tfdoc_{}_toolchain".format(version)
        tfdoc_toolchain(
            name = "{}_impl".format(toolchain_name),
            tfdoc = "@tfdoc_{}//:runtime_{}".format(version, version),
            config = "@tfdoc_{}//:config.yaml".format(version),
        )

        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = TFDOC_VERSIONS[version]["exec_compatible_with"],
            target_compatible_with = TFDOC_VERSIONS[version]["target_compatible_with"],
            toolchain = ":{}_impl".format(toolchain_name),
            toolchain_type = ":tfdoc_toolchain_type",
            visibility = ["//visibility:public"],
        )

    for version in TOFU_VERSIONS:
        toolchain_name = "tofu_{}_toolchain".format(version)
        tofu_toolchain(
            name = "{}_impl".format(toolchain_name),
            tf = "@tofu_{}//:runtime_{}".format(version, version),
        )

        native.toolchain(
            name = toolchain_name,
            exec_compatible_with = TOFU_VERSIONS[version]["exec_compatible_with"],
            target_compatible_with = TOFU_VERSIONS[version]["target_compatible_with"],
            toolchain = ":{}_impl".format(toolchain_name),
            toolchain_type = ":terraform_toolchain_type",
            visibility = ["//visibility:public"],
        )
