load("@rules_tf//tf/rules:providers.bzl", "TfModuleInfo", "TfProvidersVersionsInfo")

def _impl(ctx):
    tflint_runtime = ctx.toolchains["@rules_tf//:tflint_toolchain_type"].runtime
    tf_runtime = ctx.toolchains["@rules_tf//:terraform_toolchain_type"].runtime

    config_file = ""

    if ctx.file.config != None:
        config_file = ctx.file.config.short_path

    cmd = "{tf} -chdir={mod_dir} init -backend=false -input=false -plugin-dir=$PWD/{plugins_mirror} > /dev/null; {runner} {mod_dir} {config_file}".format(
        tf = tf_runtime.tf.path,
        runner = tflint_runtime.runner.path,
        mod_dir = ctx.label.package,
        config_file = config_file,
        plugins_mirror = ctx.attr.providers_versions[TfProvidersVersionsInfo].plugins_mirror.short_path,
    )

    deps = ctx.attr.module[TfModuleInfo].transitive_srcs.to_list() + [
        ctx.attr.providers_versions[TfProvidersVersionsInfo].plugins_mirror
    ] + tflint_runtime.deps + [tf_runtime.tf]

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )

    if ctx.file.config != None:
        deps += [ctx.file.config]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
    )]

tf_lint_test = rule(
    implementation = _impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo], allow_files = True),
        "providers_versions": attr.label(
            providers = [TfProvidersVersionsInfo],
            allow_files = True,
            mandatory = True,
        ),
        "config": attr.label(
            allow_single_file = True,
        ),
    },
    test = True,
    toolchains = [
        "@rules_tf//:terraform_toolchain_type",
        "@rules_tf//:tflint_toolchain_type",
    ],
)
