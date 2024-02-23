function shutdown
    if test -z "$argv"
        if not test (qdbus org.kde.ksmserver /KSMServer logout 0 2 1 &> /dev/null)
            sudo command shutdown now
        end
    else
        command shutdown $argv
    end
end
