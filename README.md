# hakuX-spruce

Cross-compiled [hakuX](https://github.com/rfandango/hakuX) (original Xbox) builds for [spruceOS](https://github.com/spruceUI/spruceOS).

hakuX is an Android emulator. The Linux handheld port built here is [ToastedFrog2/hakux-trimui-smart-pro](https://github.com/ToastedFrog2/hakux-trimui-smart-pro), which carries pinned hakuX and FEX source, its own platform layer and its patches.

## Build

| Output | Devices | Toolchain |
|--------|---------|-----------|
| `hakux-aarch64.tar.gz` | 64-bit spruce devices with a Vulkan driver | Zig 0.16.0, glibc 2.31 target, Cortex-A53 |

```bash
# Trigger a build
gh workflow run build.yml

# Download the output
gh release download beta-main -p "hakux-*.tar.gz"
```

## Output structure

```
hakux.aarch64        # emulator, stripped
licenses/            # hakuX and component licenses
sources.lock.json    # upstream commits the port is built from
commit_hash.txt      # port commit it was built from
```

The binary links against the device's SDL2 and loads the device's Vulkan driver.

## Patches

`patches/universal.py` lowers the glibc target and takes the panel's own display mode instead of 1280x720 only (`HAKUX_DISPLAY_WIDTH` and `HAKUX_DISPLAY_HEIGHT` force one).

`patches/spruce_menu.py` lets the firmware own the Menu button: with `HAKUX_EXTERNAL_MENU` set, the emulator ignores the button and toggles its settings menu on `SIGUSR2`.

`patches/*.patch` go through `git apply` on the port checkout, `patches/*.py` are run from its root. Both run after the port's sources are unpacked and before its own patch sequence.

## License

hakuX is GPL-3.0-or-later. Everything here is under the same license.
