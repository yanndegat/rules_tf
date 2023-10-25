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

def register_tofu_toolchain(visibility):
    toolchain_typename = "tofu_toolchain_type"
    native.toolchain_type(
        name = toolchain_typename,
        visibility = visibility,
    )

    name = "tofu_linux_amd64"
    toolchain_name = "{}_toolchain".format(name)

    tofu_toolchain(
        name = "{}_impl".format(name),
        tf = "@tofu//:runtime",
    )

    native.toolchain(
        name = toolchain_name,
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":{}_impl".format(name),
        toolchain_type = ":{}".format(toolchain_typename),
        visibility = visibility,
    )


def _download_impl(ctx):
    ctx.report_progress("Downloading tofu")

    ctx.template(
        "BUILD",
        Label("@rules_tf//tf/toolchains/tofu:BUILD.toolchain.tpl"),
        executable = False,
    )

    url_template = "https://github.com/opentofu/opentofu/releases/download/v{version}/tofu_{version}_{os}_{arch}.zip"
    url = url_template.format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    ctx.download_and_extract(
        url = url,
        sha256 = ctx.attr.sha256,
        type = "zip",
        output = "tofu",
    )

tofu_download = repository_rule(
    implementation = _download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
    },
)
