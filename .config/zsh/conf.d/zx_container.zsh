if [[ -o login ]]; then
    if which wslpath &>/dev/null; then
        export WSL_PATH="$(printf '%s:' "${(@f)$(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | sed 's/;/\n/g' | grep '\S' | xargs -r -d \\n -n 1 wslpath)}" | sed 's/:$//')"
        export WSL_HOME="$(wslpath "$(/mnt/c/Windows/system32/cmd.exe /c echo %userprofile% 2>/dev/null | sed -e 's/\r$//')")"
        export PATH="$PATH:$WSL_PATH"
        typeset -U path WSL_PATH
    fi

    if test -f /run/.containerenv; then
        export PATH="$HOME/.local/container:/usr/container:$PATH"
    fi
fi
