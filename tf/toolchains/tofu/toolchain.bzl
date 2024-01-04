TofuInfo = provider(
    doc = "Information about how to invoke Tofu.",
    fields = ["tf"],
)

def _tofu_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        runtime = TofuInfo(
            tf = ctx.file.tf,
        ),
    )
    return [toolchain_info]

tofu_toolchain = rule(
    implementation = _tofu_toolchain_impl,
    attrs = {
        "tf": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
    },
)


def _download_impl(ctx):
    ctx.report_progress("Downloading tofu")

    ctx.template(
        "BUILD",
        Label("@rules_tf//tf/toolchains/tofu:BUILD.toolchain.tpl"),
        executable = False,
        substitutions = {
            "{version}": ctx.attr.version,
            "{os}": ctx.attr.os,
            "{arch}": ctx.attr.arch,
        },
    )

    url_template = "https://github.com/opentofu/opentofu/releases/download/v{version}/tofu_{version}_{os}_{arch}.zip"
    url = url_template.format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    ctx.download_and_extract(
        url = url,
        sha256 = ctx.attr.sha256,
        type = "zip",
        output = "tofu",
    )

    return {
        "version": ctx.attr.version,
        "sha256": ctx.attr.sha256,
        "os": ctx.attr.os,
        "arch": ctx.attr.arch,
    }

tofu_download = repository_rule(
    implementation = _download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
    },
)
