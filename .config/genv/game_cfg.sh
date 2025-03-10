#!/usr/bin/env bash

case "${POSITIONAL_ARGS[*]} " in
  *"/MonsterHunterWilds.exe "*)
    USE_VKBASALT=true
    add_if_missing WINEDLLOVERRIDES \
      dinput8 \
      dstorage \
      dstoragecore
    if [[ "$GPU_VENDOR" == NVIDIA ]]; then
      add_if_missing ENV_VARS \
        PROTON_ENABLE_NGX_UPDATER=1 \
        PROTON_HIDE_NVIDIA_GPU=1 \
        PROTON_ENABLE_NVAPI=1
      add_if_missing VKD3D_DISABLE_EXTENSIONS \
        VK_NV_low_latency2
    fi
    ;;
  *"/MonsterHunterRise.exe "*)
    add_if_missing WINEDLLOVERRIDES \
      dinput8
    ;;
  *"/HoloCure.exe "*)
    USE_GAMESCOPE=true
    ;;
  *"/Terraria "*)
    if [[ "$(xrandr | grep '\*+$' | sed 's/^\s*//;s/x.*//')" -lt 1920 ]]; then
      USE_GAMESCOPE=true
      GAMESCOPE_AUTO_OUTPUT_SIZE=true
      add_if_missing GAMESCOPE_ARGS \
        --nested-height 1080 \
        --nested-width 1920
    fi
    ;;
esac
