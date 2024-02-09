load("@rules_tf//tf/rules:providers.bzl", "TfProvidersVersionsInfo")

def _impl(ctx):
    all_versions = ctx.actions.declare_file("providers-versions.json")
    providers = {}
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

    ctx.actions.write(
        output  = all_versions,
        content = json.encode(ctx.attr.providers),
    )

    return [
        DefaultInfo(files = depset([all_versions])),
        TfProvidersVersionsInfo(
            providers = providers,
            tf_version = ctx.attr.tf_version,
        ),
    ]

tf_providers_versions = rule(
    implementation = _impl,
    attrs = {
        "providers": attr.string_dict(mandatory = True),
        "tf_version": attr.string(mandatory = False),
    },
)
