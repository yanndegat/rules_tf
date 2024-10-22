#!/usr/bin/env bash

# This script aims to embed tests directoy into distro archive
# as it cannot be added into distro build directly by bazel
# as tests/bcr is bazelignored

set -eEuo pipefail

if [[ "$(git rev-parse --is-shallow-repository)" != "false" ]]; then
   git fetch --prune-tags --force --unshallow --tags
else
   git fetch --prune-tags --force --tags
fi

bazel build //distro/...

TMPDIR=$(mktemp -d)
ORIGTAR="$(find bazel-bin/distro/ -name "*.tar.gz" -type f | head -1)"
ORIGTAR="$(realpath "$ORIGTAR")"
NEWTAR="${TMPDIR}/$(basename "${ORIGTAR}")"
tar -C "$TMPDIR" -xzf "${ORIGTAR}"
cp -Rf tests "$TMPDIR"
(cd "$TMPDIR"; tar -czf "${NEWTAR}" * .??*)
cp -f "$NEWTAR" bazel-bin/distro/
