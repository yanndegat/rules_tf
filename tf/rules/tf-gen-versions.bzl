load("@rules_tf//tf/rules:providers.bzl", "TfProvidersVersionsInfo")

def _impl(ctx):
    out_file = ctx.actions.declare_file(ctx.label.name + ".sh")
    providers = ctx.attr.providers
    providers_dict_json = ctx.attr.providers_dict_json
    providers_versions = {}
    tf_version = ""

    if ctx.attr.providers_versions != None:
        providers_versions = ctx.attr.providers_versions[TfProvidersVersionsInfo].providers
        tf_version =  ctx.attr.providers_versions[TfProvidersVersionsInfo].tf_version

    # Handle both string list and dict formats for providers
    required_providers_dict = {}
    
    # Process string list format (legacy support)
    if providers:
        for p in providers:
            if p in providers_versions:
                required_providers_dict[p] = providers_versions[p]
    
    # Process dict format (new support for configuration aliases)
    if providers_dict_json:
        providers_dict = json.decode(providers_dict_json)
        for provider_name, provider_config in providers_dict.items():
            if provider_name in providers_versions:
                provider_def = dict(providers_versions[provider_name])
                
                # Add configuration_aliases if specified
                if "configuration_aliases" in provider_config:
                    provider_def["configuration_aliases"] = provider_config["configuration_aliases"]
                
                required_providers_dict[provider_name] = provider_def
            else:
                # If not in providers_versions, still include it for alias-only configs
                required_providers_dict[provider_name] = provider_config

    terraform_block = {
        "required_providers": required_providers_dict,
    }

    if tf_version != None and tf_version != "":
        terraform_block["required_version"] = tf_version

    if ctx.attr.experiments != None and len(ctx.attr.experiments) > 0:
        terraform_block["experiments"] = ctx.attr.experiments

    versions = {
        "terraform": terraform_block
    }

    cmd = "printf '%s' '{json}' > ${{BUILD_WORKSPACE_DIRECTORY:-$PWD}}/{package}/versions.tf.json".format(
        json = json.encode(versions),
        package = ctx.label.package,
    )

    ctx.actions.write(
        output = out_file,
        content = cmd,
        is_executable = True,
    )

    return [DefaultInfo(
        files = depset([out_file]),
        executable = out_file,
    )]


tf_gen_versions = rule(
    implementation = _impl,
    attrs = {
        "providers": attr.string_list(mandatory = False, default = []),
        "providers_dict_json": attr.string(mandatory = False, default = ""),
        "experiments": attr.string_list(mandatory = False, default = []),
        "tf_version": attr.string(mandatory = False, default = ""),
        "providers_versions": attr.label(
            mandatory = False,
            providers = [TfProvidersVersionsInfo],
        ),
    },
    executable = True,
)
