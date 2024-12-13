function cat --wraps=rg\ \'\'\ -N\ --colors\ match:none --description alias\ cat=rg\ \'\'\ -N\ --colors\ match:none
    if type -q rg; and test $(count $argv) -gt 1
        rg '' -N --colors match:none $argv
    else
        cat $argv
    end
end
