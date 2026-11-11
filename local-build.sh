#!/bin/bash
# Same build as the workflow, on this machine. Output lands in ./output.
set -euo pipefail
cd "$(dirname "$0")"

ENGINE="${ENGINE:-$(command -v docker || command -v podman || true)}"
[ -n "$ENGINE" ] || { echo "docker or podman is required" >&2; exit 1; }

"$ENGINE" build -t hakux-builder .
rm -rf output
mkdir -p output
"$ENGINE" run --rm \
    ${PORT_VERSION:+-e PORT_VERSION="$PORT_VERSION"} \
    ${HAKUX_GLIBC:+-e HAKUX_GLIBC="$HAKUX_GLIBC"} \
    ${JOBS:+-e JOBS="$JOBS"} \
    -v "$PWD/output:/output" \
    hakux-builder
tar czf hakux-aarch64.tar.gz -C output .
ls -la hakux-aarch64.tar.gz
