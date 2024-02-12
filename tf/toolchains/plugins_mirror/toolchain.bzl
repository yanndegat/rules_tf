load("@rules_tf//tf/toolchains:utils.bzl", "get_sha256sum")

PluginsMirrorInfo = provider(
    doc = "Information about how Plugins mirror location.",
    fields = ["dir"],
)

def _plugins_mirror_toolchain_impl(ctx):
    tf_runtime = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    providers = {}

    plugins_mirror = ctx.actions.declare_directory("plugins_mirror")
    all_versions = ctx.actions.declare_file("versions.tf.json")

    for k in ctx.attr.versions:
        v = ctx.attr.versions[k]
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

    ctx.actions.write(
        output = all_versions,
        content = json.encode(versions_tf),
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

    toolchain_info = platform_common.ToolchainInfo(
        runtime = PluginsMirrorInfo(
            dir = plugins_mirror,
        ),
    )

    return [toolchain_info]

plugins_mirror_toolchain = rule(
    implementation = _plugins_mirror_toolchain_impl,
    attrs = {
        "versions": attr.string_dict(mandatory = True),
    },
    toolchains = [
        "@rules_tf//:tf_toolchain_type",
    ],
)


def _impl(ctx):
    ctx.file( "BUILD", executable = False, )
    return

plugins_mirror = repository_rule(
    implementation = _impl,
)

DECLARE_TOOLCHAIN_CHUNK = """
plugins_mirror_toolchain(
   name = "{toolchain_repo}_toolchain_impl",
   versions = {{
      {versions}
   }},
   tags = ["no-sandbox"],
)

toolchain(
  name = "{toolchain_repo}_toolchain",
  toolchain = ":{toolchain_repo}_toolchain_impl",
  toolchain_type = "@rules_tf//:tf_plugins_mirror_toolchain_type",
  visibility = ["//visibility:public"],
)
"""
