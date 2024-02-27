TfInfo = provider(
    doc = "Information about how to invoke Terraform/Tofu.",
    fields = ["tf", "deps", "mirror"],
)

def _tf_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        runtime = TfInfo(
            tf = ctx.file.tf,
            mirror = ctx.file.mirror,
            deps = [ctx.file.tf, ctx.file.mirror],
        ),
    )
    return [toolchain_info]

tf_toolchain = rule(
    implementation = _tf_toolchain_impl,
    attrs = {
        "tf": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
        "mirror": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
    },
)
