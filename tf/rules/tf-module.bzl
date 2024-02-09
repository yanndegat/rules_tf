load("@rules_tf//tf/rules:providers.bzl", "TfModuleInfo", "TfProvidersVersionsInfo")
load("@rules_tf//tf/rules:providers.bzl", "TfArtifactInfo")
load("@rules_pkg//pkg:providers.bzl", "PackageArtifactInfo")
load("@rules_pkg//pkg:providers.bzl", "PackageFilesInfo")
load("@rules_pkg//pkg:providers.bzl", "PackageFilegroupInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _artifact_impl(ctx):
    return [
        DefaultInfo(
            files = depset([ctx.file.package]),
        ),
        TfArtifactInfo(
            module = ctx.attr.module,
            package = ctx.attr.package,
        ),
        ctx.attr.module[TfModuleInfo],
        ctx.attr.package[PackageArtifactInfo],
    ]


tf_artifact = rule(
    implementation = _artifact_impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo], mandatory = True,),
        "package": attr.label(providers = [PackageArtifactInfo], mandatory = True, allow_single_file = True),
    },
)


def _module_impl(ctx):
    if len([f for f in ctx.files.srcs if f.basename.endswith(".tf")  or f.basename.endswith(".tf.json") ]) == 0:
        fail("tf modules must contain at least one .tf file.")

    all_srcs = depset(
        ctx.files.srcs,
        transitive = [dep[TfModuleInfo].transitive_srcs if TfModuleInfo in dep else dep.files for dep in ctx.attr.deps],
    )

    return [
        DefaultInfo(
            files = all_srcs,
        ),
        TfModuleInfo(
            files = ctx.attr.srcs,
            deps = ctx.attr.deps,
            module_path = ctx.label.package,
            transitive_srcs = all_srcs,
        ),
        ctx.attr.srcs[PackageFilesInfo],
    ]

tf_module = rule(
    implementation = _module_impl,
    attrs = {
        "srcs": attr.label(mandatory = True, providers = [PackageFilesInfo, DefaultInfo]),
        "deps": attr.label_list(providers = [[TfArtifactInfo], [PackageFilegroupInfo, DefaultInfo], [PackageFilesInfo, DefaultInfo]]),
    },
)


def _compute_deps_pfi(s, prefix, files, mapped_files_depsets):
    srcFiles = s[PackageFilesInfo]
    new_pfi = PackageFilesInfo(
        dest_src_map = {
            paths.join(prefix, dest): src
                    for dest, src in srcFiles.dest_src_map.items()
        },
        attributes = srcFiles.attributes,
    )
    files.append((new_pfi, s.label))
    srcDefault = s[DefaultInfo]
    mapped_files_depsets.append(srcDefault.files)


def _compute_deps_pfgi(s, prefix, files, mapped_files_depsets):
    old_pfgi, old_di = s[PackageFilegroupInfo], s[DefaultInfo]

    files += [
        (
            PackageFilesInfo(
                dest_src_map = {
                    paths.join(prefix, dest): src
                    for dest, src in pfi.dest_src_map.items()
                },
                attributes = pfi.attributes,
            ),
            origin,
        )
        for (pfi, origin) in old_pfgi.pkg_files
    ]
    mapped_files_depsets.append(old_di.files)


def _compute_deps(dep, files, mapped_files_depsets):
    if TfModuleInfo in dep:
        depMod = dep[TfModuleInfo]
        prefix = ""

        _compute_deps_pfi(depMod.files, prefix, files, mapped_files_depsets )

        for subDep in depMod.deps:
            if PackageFilesInfo in subDep:
                _compute_deps_pfi(subDep, prefix, files, mapped_files_depsets )
            if PackageFilegroupInfo in subDep:
                _compute_deps_pfgi(subDep, prefix, files, mapped_files_depsets )


    if PackageFilesInfo in dep:
        _compute_deps_pfi(dep, "", files, mapped_files_depsets )
    if PackageFilegroupInfo in dep:
        _compute_deps_pfgi(dep, "", files, mapped_files_depsets )


def _module_deps_impl(ctx):
    files     = []
    mapped_files_depsets = []

    for dep in ctx.attr.mod[TfModuleInfo].deps:
        _compute_deps(dep, files, mapped_files_depsets )

    return [
        PackageFilegroupInfo(
            pkg_files = files,
            pkg_dirs = [],
            pkg_symlinks = [],
        ),
        # Necessary to ensure that dependent rules have access to files being
        # mapped in.
        DefaultInfo(
            files = depset(transitive = mapped_files_depsets),
        ),
    ]


tf_module_deps = rule(
    implementation = _module_deps_impl,
    attrs = {
        "mod": attr.label(providers = [TfModuleInfo]),
    },
)

def _tf_validate_impl(ctx):
    tf_runtime = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime
    tf_plugins_mirror = ctx.toolchains["@rules_tf//:tf_plugins_mirror_toolchain_type"].runtime.dir

    cmd = "{tf} -chdir={dir} init -backend=false -input=false -plugin-dir=$PWD/{plugins_mirror} > /dev/null; {tf} -chdir={dir} validate".format(
        dir = ctx.attr.module.label.package,
        tf = tf_runtime.tf.path,
        plugins_mirror = tf_plugins_mirror.short_path,
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )

    deps = ctx.attr.module[TfModuleInfo].transitive_srcs.to_list() + [
        tf_plugins_mirror,
        tf_runtime.tf,
    ]

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = deps),
    )]

tf_validate_test = rule(
    implementation = _tf_validate_impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo], allow_files = True),
    },
    test = True,
    toolchains = [
        "@rules_tf//:tf_plugins_mirror_toolchain_type",
        "@rules_tf//:tf_toolchain_type",
    ],
)


def _format_test_impl(ctx):
    module = ctx.attr.module[TfModuleInfo]
    tf_runtime = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    cmd = "{tf} fmt -check -diff {module_path}".format(
        tf = tf_runtime.tf.short_path,
        module_path = module.module_path,
    )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    runtime_deps = [
        tf_runtime.tf,
    ]
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = module.files[DefaultInfo].files.to_list() + runtime_deps),
    )]

tf_format_test = rule(
    implementation = _format_test_impl,
    attrs = {
        "module": attr.label(providers = [TfModuleInfo]),
    },
    test = True,
    toolchains = ["@rules_tf//:tf_toolchain_type"],
)

def _format_impl(ctx):
    tf_runtime = ctx.toolchains["@rules_tf//:tf_toolchain_type"].runtime

    if len(ctx.attr.modules) < 1:
        fail("you must provide a list of modules")

    cmd = "for mod in {mods}; do {tf} fmt ${{BUILD_WORKSPACE_DIRECTORY}}/${{mod}}; done".format(
        mods  = " ".join([p.label.package for p in ctx.attr.modules]),
        tf = tf_runtime.tf.short_path,
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = cmd,
    )
    runtime_deps = [
        tf_runtime.tf,
    ]
    return [DefaultInfo(
        runfiles = ctx.runfiles(files = runtime_deps),
    )]

tf_format = rule(
    implementation = _format_impl,
    attrs = {
        "modules": attr.label_list(
            mandatory = True,
        ),
    },
    toolchains = [
        "@rules_tf//:tf_toolchain_type",
    ],
    executable = True,
)
