load("@rules_tf//tf/rules:providers.bzl", "TfProvidersVersionsInfo")

def _impl(ctx):
    tf_runtime = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    providers = {}

    plugins_mirror = ctx.actions.declare_directory("plugins_mirror")
    all_versions = ctx.actions.declare_file("versions.tf.json")

    for k in ctx.attr.providers:
        v = ctx.attr.providers[k]
        elems = v.split(":")
        if len(elems) != 2:
            fail("provider version format must be org/provider:version, was: %s".format(v))

        provider_elems = elems[0].split("/")
        if len(provider_elems) != 2:
            fail("provider version format must be org/provider:version, was: %s".format(v))

        providers[k] = {
            "source": elems[0], "version": elems[1],
        }


    versions_tf = {
        "terraform": [
            {
                "required_providers": [dict([(p, providers[p]) for p in providers ])],
            }
        ]
    }

    ctx.actions.run_shell(
        outputs = [all_versions],
        command = "printf '%s' '{json}' > {file}".format(
            json = json.encode(versions_tf),
            file = all_versions.path,
        )
    )

    ctx.actions.run_shell(
        inputs = [all_versions, tf_runtime.tf],
        outputs = [plugins_mirror],
        use_default_shell_env = True,
        command = "mkdir -p {dir}; {tf} -chdir={versions_dir} providers mirror $PWD/{dir} > /dev/null".format(
            versions_dir = all_versions.dirname,
            dir = plugins_mirror.path,
            tf = tf_runtime.tf.path,
        )
    )

    runtime_deps = [ plugins_mirror, tf_runtime.tf]

    return [
        DefaultInfo( runfiles = ctx.runfiles(files = runtime_deps)),
        TfProvidersVersionsInfo(
            providers = providers,
            tf_version = ctx.attr.tf_version,
            plugins_mirror = plugins_mirror,
        ),
    ]

tf_providers_versions = rule(
    implementation = _impl,
    attrs = {
        "providers": attr.string_dict(mandatory = True),
        "tf_version": attr.string(mandatory = False),
    },
    toolchains = ["@rules_tf//:tf_toolchain_type"],
)
