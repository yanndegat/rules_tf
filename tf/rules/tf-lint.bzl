load("@rules_tf//tf/rules:providers.bzl", "TfModuleInfo")

def _impl(ctx):
    tflint_runtime = ctx.toolchains["@rules_tf//:tflint_toolchain_type"].runtime

    config_file = ""

    if ctx.file.config != None:
        config_file = ctx.file.config.short_path

    cmd = "{runner} {mod_dir} {config_file}".format(
        runner = tflint_runtime.runner.path,
        mod_dir = ctx.label.package,
        config_file = config_file,
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )

    deps = ctx.attr.module[TfModuleInfo].transitive_srcs.to_list() + tflint_runtime.deps

    if ctx.file.config != None:
        deps += [ctx.file.config]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
    )]

tf_lint_test = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo], allow_files = True),
        "config": attr.label(
            allow_single_file = True,
        ),
    },
    test = True,
    toolchains = [
        "@rules_tf//:tflint_toolchain_type",
    ],
)
