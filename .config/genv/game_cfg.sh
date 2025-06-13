#!/usr/bin/env bash

case "${POSITIONAL_ARGS[*]} " in
  *"/MonsterHunterWilds.exe "*)
    USE_VKBASALT=true
    add_if_missing WINEDLLOVERRIDES \
      dinput8 \
      dstorage \
      dstoragecore \
      dxgi \
      dlssg_to_fsr3_amd_is_better \
      dbghelp
    # add_if_missing ARGS_POST \
    #   /WineDetectionEnabled:False
    #   -dx11
    add_if_missing ENV_VARS \
      LD_PRELOAD=
    # USE_GAMESCOPE=true
    # GAMESCOPE_AUTO_NESTED_SIZE=true
    # add_if_missing GAMESCOPE_ARGS \
    #   --hdr-enabled
    if [[ "$GPU_VENDOR" == NVIDIA ]]; then
      add_if_missing ENV_VARS \
        PROTON_ENABLE_NGX_UPDATER=1 \
        PROTON_ENABLE_NVAPI=1 \
        MESA_DISK_CACHE_SINGLE_FILE=0 \
        PROTON_HIDE_NVIDIA_GPU=1
        # VKD3D_FEATURE_LEVEL=12_0
      add_if_missing VKD3D_DISABLE_EXTENSIONS \
        VK_NV_low_latency2
    fi
    ;;
  *"/MonsterHunterRise.exe "*)
    add_if_missing WINEDLLOVERRIDES \
      dinput8
    ;;
  *"/vermintide.exe "*)
    add_if_missing WINEDLLOVERRIDES \
      dinput8
    ;;
  *"/HoloCure.exe "*)
    USE_GAMESCOPE=true
    GAMESCOPE_AUTO_OUTPUT_SIZE=true
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
  *"/Last Epoch.exe "*)
    add_if_missing ENV_VARS \
      LD_PRELOAD=
    add_if_missing ARGS_POST \
      -force -d3d11
    ;;
  *"/Gw2-64.exe "*)
    add_if_missing ENV_VARS \
      DXVK_ASYNC=1
    add_if_missing ARGS_POST \
      -autologin -USEALLAVAILABLECORES
    ;;
  *"ELDEN RING NIGHTREIGN/Game/start_protected_game.exe "*)
    USE_GAMEMODE=
    USE_GAMESCOPE=true
    USE_VKBASALT=true
    add_if_missing ENV_VARS \
      LD_PRELOAD= \
      VKD3D_CONFIG=no_upload_hvv
    GAMESCOPE_AUTO_OUTPUT_SIZE=true
    GAMESCOPE_AUTO_NESTED_SIZE=true
    add_if_missing GAMESCOPE_ARGS \
      --nested-unfocused-refresh 60
    add_if_missing GAMESCOPE_ARGS \
      --force-grab-cursor
    COMMAND_PRE=(gamemoded -r \&)
    COMMAND_POST=(ps -ef \| grep -v grep \| grep -wF 'gamemoded -r' \| awk '{print $2}' \| xargs -r kill -s int)
    ;;
  *"ELDEN RING/Game/start_protected_game.exe "*)
    USE_GAMESCOPE=true
    GAMESCOPE_AUTO_OUTPUT_SIZE=true
    GAMESCOPE_AUTO_NESTED_SIZE=true
    add_if_missing GAMESCOPE_ARGS \
      --force-grab-cursor
    ;;
esac
