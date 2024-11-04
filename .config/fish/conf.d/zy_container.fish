if type -q wslpath
    if not set -q WSL_PATH
        set -x --path PATH $PATH
        set -x --path WSL_PATH $(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | xargs -r -d ';' -n 1 wslpath | grep '\S')
        for wpath in $WSL_PATH
            add-path -a PATH "$wpath"
        end
    end

    set -x WSL_HOME "$(wslpath "$(/mnt/c/Windows/system32/cmd.exe /c echo %userprofile% 2>/dev/null | sed -e 's/\r$//')")"
end

if test -f /run/.containerenv
    set -x --path PATH $PATH
    add-path -p PATH /usr/container
    add-path -p PATH ~/.local/container
end
