if command -q zypper
    function zyp --wraps=zypper --description 'alias zyp=zypper'
        if echo "$argv[1]" | rg -q '^(in|install|up|update|rm|remove|ref|refresh|ar|addrepo|rr|removerepo|nr|renamerepo|mr|modifyrepo)$'
            sudo zypper $argv
        else
            zypper $argv
        end
    end
end
