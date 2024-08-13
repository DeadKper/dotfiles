if type -q wslpath
    if not set -q WSL_PATH
        set -x --path PATH $PATH
        set -x --path WSL_PATH $(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | sd ';' '\n' | xargs -d '\n' -n 1 wslpath)
        for wpath in $WSL_PATH
            add-path -a PATH "$wpath"
        end
    end
end

if test -f /run/.containerenv
    set -x --path PATH $PATH
    add-path -p PATH /usr/container
    add-path -p PATH ~/.local/container
end
