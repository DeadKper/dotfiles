#!/usr/bin/env bash

ENV_VARS=(
  __GL_SHADER_DISK_CACHE=1
  __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
  DXVK_HUD=compiler
  PROTON_ENABLE_WAYLAND=1
  PROTON_ENABLE_HDR=1
  # WINE_CPU_TOPOLOGY=12
)
DXVK_CONFIG=()
VKD3D_CONFIG=(
  force_host_cached
)
WINEDLLOVERRIDES=()
VKD3D_DISABLE_EXTENSIONS=()
GAMESCOPE_ARGS=(
  --backend sdl
  --nested-refresh $(command -v xrandr &>/dev/null && xrandr | grep '\*+$' | sed -E 's/.*\s([0-9.]+)\*\+$/\1/' | awk '{printf("%.0f\n",$0+0.5)}' || echo 60)
)
GAMESCOPE_ENV_VARS=()
ARGS_PRE=()
ARGS_POST=()

USE_GAMEMODE=true
USE_MANGOHUD=true
USE_VKBASALT=

USE_GAMESCOPE=
GAMESCOPE_HDR=
GAMESCOPE_AUTO_OUTPUT_SIZE=true
GAMESCOPE_AUTO_NESTED_SIZE=true

COMMAND_PRE=()
COMMAND_POST=()
