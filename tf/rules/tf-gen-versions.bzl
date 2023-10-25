load("@rules_tf//tf/rules:providers.bzl", "TfProvidersVersionsInfo")

def _impl(ctx):
    out_file = ctx.actions.declare_file(ctx.label.name + ".sh")
    providers = ctx.attr.providers
    providers_versions = {}
    tf_version = ""

    if ctx.attr.providers_versions != None:
        providers_versions = ctx.attr.providers_versions[TfProvidersVersionsInfo].versions
        tf_version =  ctx.attr.providers_versions[TfProvidersVersionsInfo].tf_version

    versions = {
        "terraform": [
            {
                "required_providers": [dict([ (p, providers_versions[p])
                                              for p in ctx.attr.providers if p in providers_versions ])],
            }
        ]
    }

    if tf_version != None and tf_version != "":
        versions["terraform"][0]["required_version"] = tf_version

    ctx.actions.expand_template(
        output = out_file,
        template = ctx.file._template,
        is_executable = True,
        substitutions = {
            "@@json@@": json.encode(versions),
            "@@package@@": ctx.label.package,
        }
    )

    return [DefaultInfo(
        files = depset([out_file]),
        executable = out_file,
    )]


tf_gen_versions = rule(
    implementation = _impl,
    attrs = {
        "providers": attr.string_list(mandatory = False, default = []),
        "tf_version": attr.string(mandatory = False, default = ""),
        "providers_versions": attr.label(
            mandatory = False,
            providers = [TfProvidersVersionsInfo],
        ),
        "_template": attr.label(
            default = "//tf/rules:tf-gen-versions.sh",
            allow_single_file = True,
        ),
    },
    executable = True,
)
