#!/usr/bin/env bash
set -eEuo pipefail

package="@@package@@"

if [[ -z "${package}" ]]; then
    echo >&2 "missing package name!"
    exit 1
fi

if [ -z "${BUILD_WORKSPACE_DIRECTORY-}" ]; then
  echo "error: BUILD_WORKSPACE_DIRECTORY not set" >&2
  exit 1
fi

resolved_dir="${BUILD_WORKING_DIRECTORY}/${package}"
if [[ -z "${resolved_dir}" ]]; then
    echo >&2 "could not resolve package '${package}'."
    exit 1
fi

if [[ ! -d "${resolved_dir}" ]]; then
    echo >&2 "could not find dir '${resolved_dir}' for package '${package}'."
    exit 1
fi

printf '%s' '@@json@@' > "${resolved_dir}/versions.tf.json"
