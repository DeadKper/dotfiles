function reboot
    if test -z "$argv"
        if not test (qdbus org.kde.ksmserver /KSMServer logout 0 1 2 &> /dev/null)
            sudo shutdown -r now
        end
    else
        command reboot $argv
    end
end
