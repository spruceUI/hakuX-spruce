#!/usr/bin/env python3
"""Let the firmware own the Menu button.

spruce's menu button watchdog decides what a tap and a hold do. With
HAKUX_EXTERNAL_MENU set, the emulator stops reading the Menu button itself and
toggles its settings menu on SIGUSR2 instead:

    kill -USR2 $(pidof hakux.aarch64)

Without the variable the port behaves as before.
"""
from pathlib import Path


def replace(path, old, new):
    p = Path(path)
    s = p.read_text()
    if s.count(old) != 1:
        raise SystemExit(f"{path}: expected one match for {old!r}")
    p.write_text(s.replace(old, new))


MENU = "port/platform/menu.c"

replace(MENU, "#include <pthread.h>\n", "#include <pthread.h>\n#include <signal.h>\n")

replace(
    MENU,
    "void hakux_menu_init(int argc, char **argv)\n{\n",
    "static volatile sig_atomic_t menu_signal;\n"
    "static int menu_external;\n"
    "static void menu_signal_handler(int sig) { (void)sig; menu_signal = 1; }\n"
    "\n"
    "void hakux_menu_init(int argc, char **argv)\n{\n"
    "    menu_external = getenv(\"HAKUX_EXTERNAL_MENU\") != NULL;\n"
    "    if (menu_external) {\n"
    "        struct sigaction sa = {0};\n"
    "        sa.sa_handler = menu_signal_handler;\n"
    "        sa.sa_flags = SA_RESTART;\n"
    "        sigemptyset(&sa.sa_mask);\n"
    "        sigaction(SIGUSR2, &sa, NULL);\n"
    "    }\n",
)

replace(
    MENU,
    "    bool key=ui.key||ui.raw_key||(pad&&SDL_GameControllerGetButton(pad,SDL_CONTROLLER_BUTTON_GUIDE));\n"
    "    bool toggled=key && !ui.guide && ui.ready;\n",
    "    bool key=!menu_external&&(ui.key||ui.raw_key||(pad&&SDL_GameControllerGetButton(pad,SDL_CONTROLLER_BUTTON_GUIDE)));\n"
    "    bool toggled=key && !ui.guide && ui.ready;\n"
    "    if(menu_external) { toggled=menu_signal && ui.ready; if(ui.ready)menu_signal=0; }\n",
)
