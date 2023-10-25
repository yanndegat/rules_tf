load("@rules_pkg//pkg:providers.bzl", "PackageArtifactInfo")

def _impl(ctx):
    tfdoc_runtime = ctx.toolchains["@rules_tf//:tfdoc_toolchain_type"].runtime
    cmd = "for mod in $@; do {tfdoc} -c {config} markdown $BUILD_WORKSPACE_DIRECTORY/$mod; done".format(
        tfdoc = tfdoc_runtime.short_path,
        config = ctx.file._tfdoc_config.short_path,
    )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    runtime_deps = [
        ctx.executable._tfdoc,
        tfdoc_runtime,
    ]
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = runtime_deps),
    )]

tf_gen_doc = rule(
    implementation = _impl,
    attrs = {
        "_tfdoc_config": attr.label(
            default = Label("//tf/rules:tfdoc.yaml"),
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = [
        "@rules_tf//:tfdoc_toolchain_type",
    ],
)
