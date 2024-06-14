load("@rules_tf//tf/toolchains:utils.bzl", "get_sha256sum")

TfdocInfo = provider(
    doc = "Information about how to invoke tfdoc.",
    fields = ["tfdoc", "config", "deps"],
)

def _tfdoc_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        runtime = TfdocInfo(
            tfdoc = ctx.file.tfdoc,
            config = ctx.file.config,
            deps = [
                ctx.file.config,
                ctx.file.tfdoc,
            ],
        ),
    )
    return [toolchain_info]

tfdoc_toolchain = rule(
    implementation = _tfdoc_toolchain_impl,
    attrs = {
        "tfdoc": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
            cfg = "target",
        ),
    },
)


def _tfdoc_download_impl(ctx):
    ctx.report_progress("Downloading tfdoc")

    ctx.template(
        "BUILD",
        Label("@rules_tf//tf/toolchains/tfdoc:BUILD.toolchain.tpl"),
        executable = False,
        substitutions = {
            "{version}": ctx.attr.version,
            "{os}": ctx.attr.os,
            "{arch}": ctx.attr.arch,
        },
    )

    ctx.template(
        "config.yaml",
        ctx.attr.config,
        executable = False,
    )

    file = "terraform-docs-v{version}-{os}-{arch}.tar.gz".format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    url_template = "https://github.com/terraform-docs/terraform-docs/releases/download/v{version}/{file}"
    url = url_template.format(version = ctx.attr.version, file = file)
    url_sha256sums_template = "https://github.com/terraform-docs/terraform-docs/releases/download/v{version}/terraform-docs-v{version}.sha256sum"
    url_sha256sums = url_sha256sums_template.format(version = ctx.attr.version)

    ctx.download(
        url = [ url_sha256sums],
        output = "sha256sums",
    )

    data = ctx.read("sha256sums")
    sha256sum = get_sha256sum(data, file)
    if sha256sum == None or sha256sum == "":
        fail("Could not find sha256sum for file {}".format(file))

    res = ctx.download_and_extract(
        url = url,
        sha256 = sha256sum,
        output = "terraform-docs",
    )

    if not res.success:
        fail("!failed to dl: ", url)

    return

tfdoc_download = repository_rule(
    _tfdoc_download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
        "config": attr.label(
            mandatory = False,
            default = "@rules_tf//tf/toolchains/tfdoc:tf-doc.yaml",
            allow_single_file = True,
            cfg = "target",
        ),
    },
)

DECLARE_TOOLCHAIN_CHUNK = """
tfdoc_toolchain(
   name = "{toolchain_repo}_toolchain_impl",
   tfdoc = "@{toolchain_repo}//:runtime",
   config = "@{toolchain_repo}//:config.yaml",
)

toolchain(
  name = "{toolchain_repo}_toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":{toolchain_repo}_toolchain_impl",
  toolchain_type = "@rules_tf//:tfdoc_toolchain_type",
  visibility = ["//visibility:public"],
)
"""
