if type -q wslpath
    # if not set -q "$WSL_SSH"; and test -f "$HOME/.local/bin/wsl-ssh-agent-relay"
    #     "$HOME/.local/bin/wsl-ssh-agent-relay" start
    #     set -x SSH_AUTH_SOCK "$HOME/.ssh/wsl-ssh-agent.sock"
    # end

    set -x --path PATH $PATH
    set -x --path WSL_PATH $(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | sd ';' '\n' | xargs -d '\n' -n 1 wslpath)
    for wpath in $WSL_PATH
        add-path -a PATH "$wpath"
    end
end
