##!/usr/bin/env bash
set -eEuo pipefail

WORKDIR="${1:-}"
CUSTOM_CONFIG="${2:-}"

if [[ ! -d "${WORKDIR}" ]]; then
    echo >&2 "usage: $0 WORKDIR CUSTOM_CONFIG"
    exit 1
fi

TFLINT_DIR="$(cd "$(dirname "$0")"; echo "$PWD")"
TFLINT_CONFIG_FILE="${TFLINT_DIR}/config.hcl"

if [[ -n "${CUSTOM_CONFIG}" ]]; then
  TFLINT_CONFIG_FILE="$(readlink -f "${CUSTOM_CONFIG}")"
fi

if [[ ! -f "${TFLINT_CONFIG_FILE}" ]]; then
    echo >&2 "config file '${TFLINT_CONFIG_FILE}' is missing."
    exit 1
fi

"${TFLINT_DIR}/tflint/tflint" --init --chdir="$WORKDIR" --config="${TFLINT_CONFIG_FILE}"
"${TFLINT_DIR}/tflint/tflint" --chdir="$WORKDIR" --config="${TFLINT_CONFIG_FILE}"
