load("@rules_tf//tf/rules:providers.bzl", "TfProvidersVersionsInfo")

def _impl(ctx):
    versions = {}

    for k in ctx.attr.versions:
        v = ctx.attr.versions[k]
        elems = v.split(":")
        if len(elems) != 2:
            fail("provider version format must be org/provider:version, was: %s".format(v))

        version_elems = elems[0].split("/")
        if len(version_elems) != 2:
            fail("provider version format must be org/provider:version, was: %s".format(v))

        versions[k] = {
            "source": elems[0], "version": elems[1],
        }


    return [TfProvidersVersionsInfo(
        versions = versions,
        tf_version = ctx.attr.tf_version,
    )]

tf_providers_versions = rule(
    implementation = _impl,
    attrs = {
        "versions": attr.string_dict(mandatory = True),
        "tf_version": attr.string(mandatory = False),
    },
)
