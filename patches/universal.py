#!/usr/bin/env python3
"""Make the TG5040 port build for every 64-bit spruce device."""
import os
from pathlib import Path

glibc = os.environ.get("HAKUX_GLIBC", "2.31")


def replace(path, old, new):
    p = Path(path)
    s = p.read_text()
    if s.count(old) != 1:
        raise SystemExit(f"{path}: expected one match for {old!r}")
    p.write_text(s.replace(old, new))


for tool in ("zig-cc", "zig-cxx"):
    replace(f"port/toolchains/{tool}", "aarch64-linux-gnu.2.33", f"aarch64-linux-gnu.{glibc}")

# Take the panel's own mode instead of 1280x720 only.
replace(
    "port/platform/display.c",
    "VkResult hakux_display_surface(",
    "int hakux_display_w = 1280, hakux_display_h = 720;\n\nVkResult hakux_display_surface(",
)
replace(
    "port/platform/display.c",
    "if (ms[m].parameters.visibleRegion.width != 1280 || ms[m].parameters.visibleRegion.height != 720) continue;",
    "const char *want_w = getenv(\"HAKUX_DISPLAY_WIDTH\"), *want_h = getenv(\"HAKUX_DISPLAY_HEIGHT\");\n"
    "                if (want_w && want_h && (ms[m].parameters.visibleRegion.width != (uint32_t)atoi(want_w) ||\n"
    "                    ms[m].parameters.visibleRegion.height != (uint32_t)atoi(want_h))) continue;",
)
replace(
    "port/platform/display.c",
    "r = vkCreateDisplayPlaneSurfaceKHR(instance, &ci, NULL, out);",
    "r = vkCreateDisplayPlaneSurfaceKHR(instance, &ci, NULL, out);\n"
    "                if (r == VK_SUCCESS) {\n"
    "                    hakux_display_w = (int)ci.imageExtent.width;\n"
    "                    hakux_display_h = (int)ci.imageExtent.height;\n"
    "                }",
)
replace(
    "port/platform/frontend.c",
    "    struct ANativeWindow win = {1280,720};",
    "    extern int hakux_display_w, hakux_display_h;\n"
    "    struct ANativeWindow win = {hakux_display_w,hakux_display_h};",
)
replace(
    "port/platform/frontend.c",
    "        if (!nc_present_frame(&win)) SDL_Delay(4);",
    "        win.width = hakux_display_w; win.height = hakux_display_h;\n"
    "        if (!nc_present_frame(&win)) SDL_Delay(4);",
)
