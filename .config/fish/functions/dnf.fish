function dnf --wraps dnf
    if count $argv &> /dev/null; and echo "$argv" | grep -vE "\b(check|check-update|help|info|list|repoquery|search|updateinfo|changelog)\b" &> /dev/null
        command sudo dnf $argv
    else
        command dnf $argv
    end
end
