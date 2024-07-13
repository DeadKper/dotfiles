if command -q zypper
    function zyp --wraps=zypper --description 'alias zyp=zypper'
        if echo "$argv[1]" | rg -q '^(in|install|rm|remove)$'
            sudo zypper $argv
        else
            zypper $argv
        end
    end
end
