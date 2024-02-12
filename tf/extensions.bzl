load("@rules_tf//tf/toolchains/terraform:toolchain.bzl", "terraform_download")
load("@rules_tf//tf/toolchains/tflint:toolchain.bzl", "tflint_download")
load("@rules_tf//tf/toolchains/tfdoc:toolchain.bzl", "tfdoc_download")
load("@rules_tf//tf/toolchains/tofu:toolchain.bzl", "tofu_download")
load("@rules_tf//tf/toolchains/plugins_mirror:toolchain.bzl", _plugins_mirror = "plugins_mirror")
load("@rules_tf//tf:toolchains.bzl", "tf_toolchains", "tf_plugins_mirrors_toolchains")
load("@rules_tf//tf:versions.bzl", "TERRAFORM_VERSION")
load("@rules_tf//tf:versions.bzl", "TOFU_VERSION")
load("@rules_tf//tf:versions.bzl", "TFDOC_VERSION")
load("@rules_tf//tf:versions.bzl", "TFLINT_VERSION")

def detect_host_platform(ctx):
    os = ctx.os.name
    if os == "mac os x":
        os = "darwin"
    elif os.startswith("windows"):
        os = "windows"

    arch = ctx.os.arch
    if arch == "aarch64":
        arch = "arm64"
    elif arch == "x86_64":
        arch = "amd64"

    return os, arch

def _repo_name(*, module, tool, index, suffix = ""):
    # Keep the version out of the repository name if possible to prevent unnecessary rebuilds when
    # it changes.
    return "{name}_{version}_download_{tool}_{index}{suffix}".format(
        # "main_" is not a valid module name and thus can't collide.
        name = module.name or "main_",
        version = module.version,
        tool = tool,
        index = index,
        suffix = suffix,
    )

def _tf_repositories(ctx):
    host_detected_os, host_detected_arch = detect_host_platform(ctx)

    tflint_toolchains = []
    tfdoc_toolchains = []
    terraform_toolchains = []
    tofu_toolchains = []

    for module in ctx.modules:
        tfdoc_repo_name = _repo_name(
            module=module,
            tool = "tfdoc",
            index = 0,
            suffix = "_{}_{}".format(host_detected_os, host_detected_arch),
        )
        tfdoc_download(
            name = tfdoc_repo_name,
            version = TFDOC_VERSION,
            os = host_detected_os,
            arch = host_detected_arch,
        )
        tfdoc_toolchains += [tfdoc_repo_name]

        tflint_repo_name = _repo_name(
            module=module,
            tool = "tflint",
            index = 0,
            suffix = "_{}_{}".format(host_detected_os, host_detected_arch),
        )
        tflint_download(
            name = tflint_repo_name,
            version = TFLINT_VERSION,
            os = host_detected_os,
            arch = host_detected_arch,
        )

        tflint_toolchains += [tflint_repo_name]

        for index, version_tag in enumerate(module.tags.download):
            tf_repo_name = _repo_name(
                module=module,
                tool = "tf",
                index = index,
                suffix = "_{}_{}".format(host_detected_os, host_detected_arch),
            )

            if version_tag.use_tofu:
                tofu_download(
                    name = tf_repo_name,
                    version = version_tag.version,
                    os = host_detected_os,
                    arch = host_detected_arch,
                )
                tofu_toolchains += [tf_repo_name]
            else:
                terraform_download(
                    name = tf_repo_name,
                    version = version_tag.version,
                    os = host_detected_os,
                    arch = host_detected_arch,
                )
                terraform_toolchains += [tf_repo_name]

    tf_toolchains(
        name = "tf_toolchains",
        tflint_repos = tflint_toolchains,
        tfdoc_repos = tfdoc_toolchains,
        terraform_repos = terraform_toolchains,
        tofu_repos = tofu_toolchains,
        os = host_detected_os,
        arch = host_detected_arch,
    )

_version_tag = tag_class(
    attrs = {
        "use_tofu": attr.bool(mandatory = True, default = False),
        "version": attr.string(mandatory = True),
    },
)

tf_repositories = module_extension(
    implementation = _tf_repositories,
    tag_classes = {
        "download": _version_tag,
    },
    os_dependent = True,
    arch_dependent = True,
)


def _plugins_mirror_ext_impl(ctx):
    mirror_toolchains = {}

    for module in ctx.modules:
        for index, version_tag in enumerate(module.tags.versions):
            repo_name = _repo_name(
                module = module,
                tool = "tf_plugins_mirror",
                index = index,
                suffix = version_tag.name,
            )

            _plugins_mirror(
                name = repo_name,
            )

            mirror_toolchains[repo_name] = ",".join(["'{}': '{}'".format(k, version_tag.versions[k]) for k in version_tag.versions])

    tf_plugins_mirrors_toolchains(
        name = "tf_plugins_mirrors",
        mirror_repos = mirror_toolchains,
    )

_plugins_mirror_tag = tag_class(attrs = {
    "name": attr.string(mandatory = True),
    "versions": attr.string_dict(mandatory = True),
})

plugins_mirror = module_extension(
    implementation = _plugins_mirror_ext_impl,
    tag_classes = {
        "versions": _plugins_mirror_tag,
    },
    os_dependent = True,
    arch_dependent = True,
)

