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

def register_tfdoc_toolchain(version, visibility):
    name = "tfdoc-{}_linux_amd64".format(version)
    toolchain_name = "{}_toolchain".format(name)

    tfdoc_toolchain(
        name  = "{}_impl".format(name),
        tfdoc = "@tfdoc-{}//:runtime".format(version),
        config = "@tfdoc-{}//:config.yaml".format(version),
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
        toolchain_type = "@rules_tf//:tfdoc_toolchain_type",
        visibility = visibility,
    )



def _tfdoc_download_impl(ctx):
    ctx.report_progress("Downloading tfdoc")

    ctx.template(
        "BUILD",
        Label("@rules_tf//tf/toolchains/tfdoc:BUILD.toolchain.tpl"),
        executable = False,
    )

    ctx.template(
        "config.yaml",
        ctx.attr.config,
        executable = False,
    )

    url_template = "https://github.com/terraform-docs/terraform-docs/releases/download/v{version}/terraform-docs-v{version}-{os}-{arch}.tar.gz"
    url = url_template.format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    ctx.download_and_extract(
        url = url,
        sha256 = ctx.attr.sha256,
        output = "terraform-docs",
    )

tfdoc_download = repository_rule(
    _tfdoc_download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
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
