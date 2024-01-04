load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_download")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "tflint_download")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "tfdoc_download")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "tofu_download")
load("@rules_tf//tf:versions.bzl", "TERRAFORM_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TFDOC_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TFLINT_VERSIONS")
load("@rules_tf//tf:versions.bzl", "TOFU_VERSIONS")

def _tf_repositories(ctx):
    for module in ctx.modules:
        for version in TERRAFORM_VERSIONS:
            if not module.is_root and not version:
                fail("download: version must be specified in non-root module " + module.name)

            terraform_download(
                name = "terraform_{}".format(version),
                version = TERRAFORM_VERSIONS[version]["version"],
                sha256 = TERRAFORM_VERSIONS[version]["sha256"],
                os = TERRAFORM_VERSIONS[version]["os"],
                arch = TERRAFORM_VERSIONS[version]["arch"],
            )

        for version in TFDOC_VERSIONS:
            if not module.is_root and not version:
                fail("download: version must be specified in non-root module " + module.name)

            tfdoc_download(
                name = "tfdoc_{}".format(version),
                version = TFDOC_VERSIONS[version]["version"],
                sha256 = TFDOC_VERSIONS[version]["sha256"],
                os = TFDOC_VERSIONS[version]["os"],
                arch = TFDOC_VERSIONS[version]["arch"],
            )

        for version in TFLINT_VERSIONS:
            if not module.is_root and not version:
                fail("download: version must be specified in non-root module " + module.name)

            tflint_download(
                name = "tflint_{}".format(version),
                version = TFLINT_VERSIONS[version]["version"],
                sha256 = TFLINT_VERSIONS[version]["sha256"],
                os = TFLINT_VERSIONS[version]["os"],
                arch = TFLINT_VERSIONS[version]["arch"],
            )

        for version in TOFU_VERSIONS:
            if not module.is_root and not version:
                fail("download: version must be specified in non-root module " + module.name)

            tofu_download(
                name = "tofu_{}".format(version),
                version = TOFU_VERSIONS[version]["version"],
                sha256 = TOFU_VERSIONS[version]["sha256"],
                os = TOFU_VERSIONS[version]["os"],
                arch = TOFU_VERSIONS[version]["arch"],
            )


tf_repositories = module_extension(
    implementation = _tf_repositories,
)
