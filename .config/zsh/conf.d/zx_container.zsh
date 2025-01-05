if which wslpath &>/dev/null; then
    if [[ -o login ]] && test -z "${WSL_PATH+1}"; then
        wsl_path=("${(@f)$(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | sed 's/;/\n/g' | grep '\S' | xargs -r -d \\n -n 1 wslpath)}")
        export WSL_PATH="$(printf '%s:' "${WSL_PATH[@]}" | sed 's/:$//')"
        typeset -U wsl_path WSL_PATH
        export WSL_HOME="$(wslpath "$(/mnt/c/Windows/system32/cmd.exe /c echo %userprofile% 2>/dev/null | sed -e 's/\r$//')")"
    fi

    path+=("${wsl_path[@]}")
fi

if test -f /run/.containerenv; then
    path+=("$HOME/.local/container" "/usr/container")
fi
