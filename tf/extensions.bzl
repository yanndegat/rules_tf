load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_download")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "tflint_download")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "tfdoc_download")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "tofu_download")
load("@rules_tf//tf:versions.bzl", "TERRAFORM_VERSION")
load("@rules_tf//tf:versions.bzl", "TOFU_VERSION")
load("@rules_tf//tf:versions.bzl", "TFDOC_VERSION")
load("@rules_tf//tf:versions.bzl", "TFLINT_VERSION")

def detect_host_platform(ctx):
    os = ctx.os.name
    if os == "mac os x":
        os = "darwin"
    elif os.startswith("windows"):
        os = "windows"

    arch = ctx.os.arch
    if arch == "aarch64":
        arch = "arm64"
    elif arch == "x86_64":
        arch = "amd64"

    return os, arch


def _tools_repositories(ctx):
    host_detected_os, host_detected_arch = detect_host_platform(ctx)

    for module in ctx.modules:
        tfdoc_download(
            name = "tfdoc_binary",
            version = TFDOC_VERSION,
            os = host_detected_os,
            arch = host_detected_arch,
        )

        tflint_download(
            name = "tflint_binary",
            version = TFLINT_VERSION,
            os = host_detected_os,
            arch = host_detected_arch,
        )

tools_repositories = module_extension(
    implementation = _tools_repositories,
    os_dependent = True,
    arch_dependent = True,
)

def _tf_repositories(ctx):
    host_detected_os, host_detected_arch = detect_host_platform(ctx)

    for module in ctx.modules:
        for index, version_tag in enumerate(module.tags.download):
            if version_tag.use_tofu:
                tofu_download(
                    name = "tf_binary",
                    version = version_tag.version,
                    os = host_detected_os,
                    arch = host_detected_arch,
                )
            else:
                terraform_download(
                    name = "tf_binary",
                    version = version_tag.version,
                    os = host_detected_os,
                    arch = host_detected_arch,
                )


_version_tag = tag_class(
    attrs = {
        "use_tofu": attr.bool(mandatory = True, default = False),
        "version": attr.string(mandatory = True),
    },
)


tf_repositories = module_extension(
    implementation = _tf_repositories,
    tag_classes = {
        "download": _version_tag,
    },
    os_dependent = True,
    arch_dependent = True,
)
