function ssh
    if test (count $argv) -eq 0
        set -f files
        for file in (find ~/Documents/ssh -type f)
            set -a files (echo "$file" | sed -E "s,^$HOME,~,")
        end

        set -f credentials (printf '%s\n' $files | sort | fzf | sed -E "s,^~,$HOME,")

        if test -z "$credentials"
            return 1
        end

        source "$credentials"

        set -f command "ssh $user@$ip"

        if test -n "$port"
            set command "$command -p $port"
        end

        if test -n "$password"
            set command "sshpass -p \"$password\" $command"
        end

        eval $command
    else
        command ssh $argv
    end
end
