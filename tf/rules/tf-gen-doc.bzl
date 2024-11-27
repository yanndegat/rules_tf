load("@rules_pkg//pkg:providers.bzl", "PackageArtifactInfo")

def _impl(ctx):
    tfdoc_runtime = ctx.toolchains["@rules_tf//:tfdoc_toolchain_type"].runtime
    config_file = tfdoc_runtime.config

    if ctx.file.config != None:
        config_file = ctx.file.config

    if len(ctx.attr.modules) < 1:
        fail("you must provide a list of modules")

    cmd = "for mod in {mods}; do {tfdoc} -c {config} markdown ${{BUILD_WORKSPACE_DIRECTORY}}/${{mod}}; done".format(
        mods  = " ".join([p.label.package for p in ctx.attr.modules]),
        tfdoc = tfdoc_runtime.tfdoc.short_path,
        tfdoc_short = tfdoc_runtime.tfdoc.short_path,
        config = config_file.short_path,
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )

    runtime_deps = [
        config_file,
    ] + tfdoc_runtime.deps

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = runtime_deps),
    )]

tf_gen_doc = rule(
    implementation = _impl,
    attrs = {
        "modules": attr.label_list(
            mandatory = True,
        ),
        "config": attr.label(
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = [
        "@rules_tf//:tfdoc_toolchain_type",
    ],
)
