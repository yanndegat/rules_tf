TfModuleInfo = provider(
    doc = "Contains information about a Tf module",
    fields = [
        "files",
        "deps",
        "transitive_srcs",
        "module_path",
    ],
)

TfProvidersVersionsInfo = provider(
    doc = "Contains information about a Tf providers versions",
    fields = [
        "providers",
        "tf_version",
        "plugins_mirror",
    ],
)

TfArtifactInfo = provider(
    doc = "Contains information about a Tf artifact: module and package info",
    fields = [
        "module",
        "package",
    ],
)
