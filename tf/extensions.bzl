load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_download")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "tflint_download")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "tfdoc_download")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "tofu_download")


def _tf_repositories(ctx):
    for module in ctx.modules:
        for index, download_tag in enumerate(module.tags.download_terraform):
            if not module.is_root and not download_tag.version:
                fail("download: version must be specified in non-root module " + module.name)

            terraform_download(
                name = "terraform-{}".format(download_tag.version),
                version = download_tag.version,
                sha256 = download_tag.sha256,
                os = download_tag.os,
                arch = download_tag.arch,
            )
        for index, download_tag in enumerate(module.tags.download_tfdoc):
            tfdoc_download(
                name = "tfdoc-{}".format(download_tag.version),
                version = download_tag.version,
                sha256 = download_tag.sha256,
                os = download_tag.os,
                arch = download_tag.arch,
            )
        for index, download_tag in enumerate(module.tags.download_tflint):
            tflint_download(
                name = "tflint-{}".format(download_tag.version),
                version = download_tag.version,
                sha256 = download_tag.sha256,
                os = download_tag.os,
                arch = download_tag.arch,
            )
        for index, download_tag in enumerate(module.tags.download_tofu):
            tofu_download(
                name = "tofu-{}".format(download_tag.version),
                version = download_tag.version,
                sha256 = download_tag.sha256,
                os = download_tag.os,
                arch = download_tag.arch,
            )


_download_tag = tag_class(
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
    },
)

tf_repositories = module_extension(
    implementation = _tf_repositories,
    tag_classes = {
        "download_terraform": _download_tag,
        "download_tfdoc": _download_tag,
        "download_tflint": _download_tag,
        "download_tofu": _download_tag,
    },
)
