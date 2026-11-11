#!/bin/bash
set -euo pipefail

PORT_REPO="${PORT_REPO:-https://github.com/ToastedFrog2/hakux-trimui-smart-pro.git}"
PORT_VERSION="${PORT_VERSION:-b404a6228523f2bc7507209d815281629eee1e5f}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"

echo "=== Cloning the hakuX Linux port $PORT_VERSION ==="
git clone "$PORT_REPO" hakux
cd hakux
git checkout "$PORT_VERSION"

python3 port/unpack-sources.py
cp /opt/sdl2/libSDL2.so port/deps/lib/libSDL2.so

# A patch that fails must fail the build.
for patch in /patches/*.patch; do
    [ -f "$patch" ] || continue
    echo "=== Applying $(basename "$patch") ==="
    git apply "$patch"
done
for patch in /patches/*.py; do
    [ -f "$patch" ] || continue
    echo "=== Running $(basename "$patch") ==="
    python3 "$patch"
done

export ZIG="$(command -v zig)"
export TRIMUI_STRIP="$(command -v llvm-strip)"
export JOBS="${JOBS:-$(nproc)}"
bash port/build-xbox2.sh

mkdir -p "$OUTPUT_DIR/licenses"
cp port/dist/hakux.aarch64 "$OUTPUT_DIR/"
cp COPYING "$OUTPUT_DIR/licenses/hakuX-COPYING"
cp LICENSE "$OUTPUT_DIR/licenses/hakuX-LICENSE"
cp port/source/licenses/* "$OUTPUT_DIR/licenses/"
cp port/sources.lock.json "$OUTPUT_DIR/sources.lock.json"
git rev-parse HEAD > "$OUTPUT_DIR/commit_hash.txt"

echo "=== Done ==="
ls -la "$OUTPUT_DIR"
