# Kept deliberately in sync with tf/toolchains/terraform/toolchain.bzl: the two
# differ only by engine name, registry host and release URL. A change here
# almost always belongs there too.
load("@rules_tf//tf/toolchains:utils.bzl", "get_sha256sum")

_HEX = "0123456789abcdef"

# The registry a provider address is qualified with. tofu resolves providers
# against registry.opentofu.org, and the mirror directory it consumes under -plugin-dir is
# laid out under that same hostname.
_REGISTRY = "registry.opentofu.org"

def _platform_key(ctx):
    """The key under which per-platform pins are looked up."""
    return "{}/{}".format(ctx.attr.os, ctx.attr.arch)

def _read_pins(ctx, attr_name, label):
    """Reads a pins file: a JSON object mapping an artifact to its per-platform origins."""
    content = ctx.read(ctx.path(label))

    # Catches the realistic failure in the environments this feature targets: a
    # proxy answering with an HTML error page instead of the file. Checking the
    # first character keeps the attribute and the path in the message, which a
    # bare decoder error would not carry. json.decode's 'default' parameter
    # would be the obvious way to do this, but it needs Bazel 7 and this
    # ruleset still supports 6.x.
    if not content.strip().startswith("{"):
        fail("tofu_download: '{attr}' must contain a JSON object keyed by artifact: {file} starts with {head}.".format(
            attr = attr_name,
            file = label,
            head = repr(content.strip()[:40]) if content.strip() else "an empty file",
        ))

    pins = json.decode(content)
    if type(pins) != "dict":
        fail("tofu_download: '{attr}' must contain a JSON object keyed by artifact: {file} decoded to a {got}.".format(
            attr = attr_name,
            file = label,
            got = type(pins),
        ))

    return pins

def _pin_for_platform(ctx, attr_name, pins, key, want_version):
    """Resolves one artifact's url and sha256 for the platform being built.

    Every lookup failure is reported with what was wanted and what the file
    actually offers, because a pins file is generated and the mismatch is
    usually between it and the rest of the build, not inside it.
    """
    entry = pins.get(key)
    if entry == None:
        fail("tofu_download: '{attr}' has no entry for '{key}'. Entries present: {present}.".format(
            attr = attr_name,
            key = key,
            present = ", ".join(sorted(pins.keys())) if pins else "none",
        ))

    if type(entry) != "dict" or "platforms" not in entry:
        fail("tofu_download: '{attr}' entry '{key}' must be an object with a 'platforms' field.".format(
            attr = attr_name,
            key = key,
        ))

    # 'version' is what stops the pins drifting from the rest of the build, so a
    # missing one is reported as the structural error it is rather than as a
    # mismatch against a version the user cannot find in the file.
    if type(entry.get("version")) != "string":
        fail("tofu_download: '{attr}' entry '{key}' is missing a string 'version' field.".format(
            attr = attr_name,
            key = key,
        ))

    if entry.get("version") != want_version:
        fail("tofu_download: '{attr}' pins '{key}' at version {have}, but the build requires {want}. ".format(
            attr = attr_name,
            key = key,
            have = entry.get("version"),
            want = want_version,
        ) + "Regenerate the pins file.")

    platform = _platform_key(ctx)
    platforms = entry["platforms"]
    if type(platforms) != "dict":
        fail("tofu_download: '{attr}' entry '{key}' has a non-object 'platforms' field.".format(
            attr = attr_name,
            key = key,
        ))

    if not platforms:
        fail("tofu_download: '{attr}' entry '{key}' has an empty 'platforms' map.".format(
            attr = attr_name,
            key = key,
        ))

    pin = platforms.get(platform)
    if pin == None:
        fail("tofu_download: '{attr}' has no pin for '{key}' on platform '{platform}'. ".format(
            attr = attr_name,
            key = key,
            platform = platform,
        ) + "Pins are per-platform because each platform has its own artifact. " +
             "Supplied platforms: {}.".format(", ".join(sorted(platforms.keys()))))

    if type(pin) != "dict":
        fail("tofu_download: '{attr}' pin for '{key}' on '{platform}' must be an object with 'url' and 'sha256'.".format(
            attr = attr_name,
            key = key,
            platform = platform,
        ))

    url = pin.get("url")
    sha256 = pin.get("sha256")
    if not url or not sha256:
        fail("tofu_download: '{attr}' pin for '{key}' on '{platform}' needs both 'url' and 'sha256'.".format(
            attr = attr_name,
            key = key,
            platform = platform,
        ))

    if type(url) != "string" or type(sha256) != "string":
        fail("tofu_download: '{attr}' pin for '{key}' on '{platform}' must give 'url' and 'sha256' as strings.".format(
            attr = attr_name,
            key = key,
            platform = platform,
        ))

    # Bazel accepts either case; some generators and checksum tools emit upper.
    sha256 = sha256.lower()
    if len(sha256) != 64 or not all([c in _HEX for c in sha256.elems()]):
        fail("tofu_download: '{attr}' pin for '{key}' on '{platform}' has a malformed 'sha256'. ".format(
            attr = attr_name,
            key = key,
            platform = platform,
        ) + "A sha256 digest is 64 lowercase hexadecimal characters.")

    return url, sha256

def _download_cli(ctx):
    """Fetches the tofu CLI, extracting the executable to 'tofu/tofu'."""
    if ctx.attr.cli_pins:
        pins = _read_pins(ctx, "cli_pins", ctx.attr.cli_pins)
        url, sha256 = _pin_for_platform(ctx, "cli_pins", pins, "tofu", ctx.attr.version)
        res = ctx.download_and_extract(
            url = url,
            sha256 = sha256,
            type = "zip",
            output = "tofu",
        )

        if not res.success:
            fail("tofu_download: failed to download the CLI archive for '{platform}' from '{url}'.".format(
                platform = _platform_key(ctx),
                url = url,
            ))

        # 'exists' alone is not enough: zipping the containing directory rather
        # than its contents produces 'tofu/tofu' as a *directory*, which is the
        # most likely packing mistake and would otherwise pass this check.
        # path.is_dir needs Bazel 7.1 and this ruleset still supports 6.x, so
        # shell out instead. The probe is skipped on Windows, which has no
        # 'test' binary. That is not a regression: the default path already
        # assumes a non-'.exe' binary name, so Windows was never supported.
        cli_is_file = ctx.attr.os == "windows" or ctx.execute(["test", "-f", "tofu/tofu"]).return_code == 0
        if not ctx.path("tofu/tofu").exists or not cli_is_file:
            fail("tofu_download: the archive named by 'cli_pins' does not contain the " +
                 "expected layout. The 'tofu' executable must be at the root of the archive " +
                 "so that it is extracted to 'tofu/tofu'.")

        # Some packers drop the POSIX mode bits, which would otherwise surface
        # much later as a permission error from a build action.
        if ctx.attr.os != "windows":
            chmod = ctx.execute(["chmod", "+x", "tofu/tofu"])
            if chmod.return_code != 0:
                fail("tofu_download: could not make the pinned CLI executable: {err}".format(
                    err = chmod.stderr.strip() or "chmod exited {}".format(chmod.return_code),
                ))

        return

    file = "tofu_{version}_{os}_{arch}.zip".format(version = ctx.attr.version, os = ctx.attr.os, arch = ctx.attr.arch)

    url_template = "https://github.com/opentofu/opentofu/releases/download/v{version}/{file}"
    url = url_template.format(version = ctx.attr.version, file = file)

    url_sha256sums_template = "https://github.com/opentofu/opentofu/releases/download/v{version}/tofu_{version}_SHA256SUMS"
    url_sha256sums = url_sha256sums_template.format(version = ctx.attr.version)

    ctx.download(
        url = [ url_sha256sums],
        output = "sha256sums",
    )

    data = ctx.read("sha256sums")
    sha256sum = get_sha256sum(data, file)
    if sha256sum == None or sha256sum == "":
        fail("Could not find sha256sum for file {}".format(file))

    res = ctx.download_and_extract(
        url = url,
        sha256 = sha256sum,
        type = "zip",
        output = "tofu",
    )

    if not res.success:
        fail("!failed to dl: ", url)

def _setup_mirror(ctx):
    """Populates the repository-root 'mirror' directory with the providers."""
    providers = {}
    for k in ctx.attr.mirror:
        v = ctx.attr.mirror[k]
        elems = v.split(":")
        if len(elems) != 2:
            fail("provider version format must be org/provider:x.y.x, was: %s".format(v))

        provider_elems = elems[0].split("/")
        if len(provider_elems) != 2:
            fail("provider version format must be org/provider:x.y.z, was: %s".format(v))

        version = elems[1]
        version_elems = version.split(".")
        if len(version_elems) != 3:
            fail("provider version format must be org/provider:x.y.z, was: %s".format(v))

        providers[k] = {
            "source": elems[0], "version": elems[1],
        }

    # A pins file makes the whole mirror the rule's own responsibility: every
    # provider is fetched through Bazel's downloader, so URL rewrites, the
    # repository cache and .netrc all apply. The 'tofu providers mirror'
    # subprocess below cannot honour any of them, because it performs its own
    # network I/O outside Bazel.
    if ctx.attr.provider_pins:
        pins = _read_pins(ctx, "provider_pins", ctx.attr.provider_pins)
        for spec in providers.values():
            source = spec["source"].lower()
            version = spec["version"]

            # Registry addresses are lowercase, while call sites write the
            # registry's display casing, e.g. 'Azure/azapi'.
            address = "{registry}/{source}".format(registry = _REGISTRY, source = source)
            url, sha256 = _pin_for_platform(ctx, "provider_pins", pins, address, version)

            # The layout is the rule's to construct, not the caller's: it is
            # exacting, and tofu reports a wrong one only as a missing
            # provider. Note the file name says 'terraform-provider' whichever
            # engine consumes it.
            namespace, provider_type = source.split("/")
            out = "mirror/{registry}/{namespace}/{provider_type}/terraform-provider-{provider_type}_{version}_{os}_{arch}.zip".format(
                registry = _REGISTRY,
                namespace = namespace,
                provider_type = provider_type,
                version = version,
                os = ctx.attr.os,
                arch = ctx.attr.arch,
            )

            res = ctx.download(url = url, output = out, sha256 = sha256)
            if not res.success:
                fail("tofu_download: failed to download provider '{address}' for '{platform}' from '{url}'.".format(
                    address = address,
                    platform = _platform_key(ctx),
                    url = url,
                ))

        # 'mirror' is exported by the generated BUILD file, so the directory has
        # to exist even when no providers were pinned. The default path gets
        # this from its 'mkdir -p mirror'.
        ctx.file("mirror/.keep", content = "")

        return

    versions_tf = {
        "terraform": [
            {
                "required_providers": [dict([(p, providers[p]) for p in providers ])],
            }
        ]
    }

    ctx.file("versions.tf.json", content = json.encode(versions_tf))

    ctx.execute([
        "bash",
        "-c",
        "mkdir -p mirror; tofu/tofu providers mirror ./mirror > /dev/null",
        ])

def _download_impl(ctx):
    ctx.report_progress("Downloading tofu")

    ctx.template(
        "BUILD",
        Label("@rules_tf//tf/toolchains/tofu:BUILD.toolchain.tpl"),
        executable = False,
        substitutions = {
            "{version}": ctx.attr.version,
            "{os}": ctx.attr.os,
            "{arch}": ctx.attr.arch,
        },
    )

    _download_cli(ctx)
    _setup_mirror(ctx)

    return

tofu_download = repository_rule(
    implementation = _download_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "os": attr.string(mandatory = True),
        "arch": attr.string(mandatory = True),
        "mirror": attr.string_dict(mandatory = True),
        # Pins files state, per platform, where an artifact is and what it must
        # hash to. They are optional: without them the CLI comes from its
        # upstream release host and the mirror is populated by the
        # 'tofu providers mirror' subprocess, exactly as before.
        "cli_pins": attr.label(
            allow_single_file = [".json"],
            doc = "JSON file pinning the CLI: per platform, the URL to fetch and its sha256. Each entry also carries a 'version', cross-checked against the 'version' attribute. Unset, the CLI is fetched from its upstream release host. See the README for the schema.",
        ),
        "provider_pins": attr.label(
            allow_single_file = [".json"],
            doc = "JSON file pinning provider plugins, keyed by registry address: per platform, the URL to fetch and its sha256. Each entry also carries a 'version', cross-checked against 'mirror'. Unset, the mirror is populated by the 'providers mirror' subprocess. See the README for the schema.",
        ),
    },
)

DECLARE_TOOLCHAIN_CHUNK = """
tf_toolchain(
   name = "{toolchain_repo}_toolchain_impl",
   tf = "@{toolchain_repo}//:runtime",
   mirror = "@{toolchain_repo}//:mirror",
)

toolchain(
  name = "{toolchain_repo}_toolchain",
  exec_compatible_with = platforms["{os}_{arch}"]["exec_compatible_with"],
  target_compatible_with = platforms["{os}_{arch}"]["target_compatible_with"],
  toolchain = ":{toolchain_repo}_toolchain_impl",
  toolchain_type = "@rules_tf//:tf_toolchain_type",
  visibility = ["//visibility:public"],
)

alias(
    name = "tofu",
    actual = "@{toolchain_repo}//:runtime",
)
"""
