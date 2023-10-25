load("@rules_tf//tf/rules:providers.bzl", "TfModuleInfo")

def _impl(ctx):
    tflint_runtime = ctx.toolchains["@rules_tf//:tflint_toolchain_type"].runtime

    cmd = "{runner} {mod_dir}".format(
        runner = tflint_runtime.runner.path,
        mod_dir = ctx.label.package,
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )

    deps = ctx.attr.module[TfModuleInfo].transitive_srcs.to_list() + tflint_runtime.deps

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
    )]

tf_lint_test = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo], allow_files = True),
    },
    test = True,
    toolchains = [
        "@rules_tf//:tflint_toolchain_type",
    ],
)
