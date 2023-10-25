TflintInfo = provider(
    doc = "Information about how to invoke tflint.",
    fields = ["runner", "deps"],
)

def _tflint_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        runtime = TflintInfo(
            runner = ctx.file.wrapper,
            deps = ctx.files.bash_tools + [
                ctx.file.wrapper,
                ctx.file.config,
                ctx.file.tflint,
            ],
        ),
    )
    return [toolchain_info]

tflint_toolchain = rule(
    implementation = _tflint_toolchain_impl,
    attrs = {
        "tflint": attr.label(
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
        "wrapper": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
        "bash_tools": attr.label(
            mandatory = False,
            default = "@bazel_tools//tools/bash/runfiles",
            allow_files = True,
            cfg = "target",
        ),
    },
)

def register_tflint_toolchain(visibility):
    toolchain_typename = "tflint_toolchain_type"
    native.toolchain_type(
        name = toolchain_typename,
        visibility = visibility,
    )

    name = "tflint_linux_amd64"
    toolchain_name = "{}_toolchain".format(name)

    tflint_toolchain(
        name = "{}_impl".format(name),
        tflint = "@tflint//:runtime",
        config = "@tflint//:config.hcl",
        wrapper = "@tflint//:wrapper.sh",
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


def _tflint_download_impl(ctx):
    ctx.report_progress("Downloading tflint")

    ctx.template(
        "BUILD.bazel",
        Label("@rules_tf//tf/toolchains/tflint:BUILD.toolchain.tpl"),
        executable = False,
    )

    ctx.template(
        "wrapper.sh",
        Label("@rules_tf//tf/toolchains/tflint:wrapper.sh"),
        executable = True,
    )

    ctx.template(
        "config.hcl",
        ctx.attr.config,
        executable = False,
    )

    url_template = "https://github.com/terraform-linters/tflint/releases/download/v{version}/tflint_{os}_{arch}.zip"
    url = url_template.format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    ctx.download_and_extract(
        url = url,
        sha256 = ctx.attr.sha256,
        type = "zip",
        output = "tflint",
    )


tflint_download = repository_rule(
    _tflint_download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
        "config": attr.label(
            mandatory = False,
            default = "@rules_tf//tf/toolchains/tflint:config.hcl",
            allow_single_file = True,
            cfg = "target",
        ),
    },
)
