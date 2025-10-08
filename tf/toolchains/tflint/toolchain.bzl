load("@rules_tf//tf/toolchains:utils.bzl", "get_sha256sum")

TflintInfo = provider(
    doc = "Information about how to invoke tflint.",
    fields = ["runner", "deps", "config", "tflint_plugins"],
)

def _tflint_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        runtime = TflintInfo(
            runner = ctx.file.wrapper,
            config = ctx.file.config,
            tflint_plugins = ctx.file.tflint_plugins,
            deps = ctx.files.bash_tools + [
                ctx.file.wrapper,
                ctx.file.config,
                ctx.file.tflint,
                ctx.file.tflint_plugins,
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
        "tflint_plugins": attr.label(
            mandatory = True,
            allow_single_file = True,
            cfg = "target",
        ),
    },
)

def _tflint_download_impl(ctx):
    ctx.report_progress("Downloading tflint")

    ctx.template(
        "BUILD.bazel",
        Label("@rules_tf//tf/toolchains/tflint:BUILD.toolchain.tpl"),
        executable = False,
        substitutions = {
            "{version}": ctx.attr.version,
            "{os}": ctx.attr.os,
            "{arch}": ctx.attr.arch,
        },
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

    file = "tflint_{os}_{arch}.zip".format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)
    url_template = "https://github.com/terraform-linters/tflint/releases/download/v{version}/{file}"
    url = url_template.format(version = ctx.attr.version, file = file)
    url_sha256sums_template = "https://github.com/terraform-linters/tflint/releases/download/v{version}/checksums.txt"
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
        type = "zip",
        output = "tflint",
    )

    if not res.success:
        fail("!failed to dl: ", url)

    res = ctx.execute([
        "bash",
        "-c",
        "mkdir -p tflint_plugins; TFLINT_PLUGIN_DIR=./tflint_plugins tflint/tflint -c ./config.hcl --init",
    ])

    return

tflint_download = repository_rule(
    _tflint_download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
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

DECLARE_TOOLCHAIN_CHUNK = """
tflint_toolchain(
   name = "{toolchain_repo}_toolchain_impl",
   tflint = "@{toolchain_repo}//:runtime",
   config = "@{toolchain_repo}//:config.hcl",
   wrapper = "@{toolchain_repo}//:wrapper.sh",
   tflint_plugins = "@{toolchain_repo}//:tflint_plugins",
)

toolchain(
  name = "{toolchain_repo}_toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":{toolchain_repo}_toolchain_impl",
  toolchain_type = "@rules_tf//:tflint_toolchain_type",
  visibility = ["//visibility:public"],
)

alias(
    name = "tflint",
    actual = "@{toolchain_repo}//:runtime",
)
"""
