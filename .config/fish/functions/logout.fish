function logout
    if not test (qdbus org.kde.ksmserver /KSMServer logout 0 0 2 &> /dev/null)
        pkill -U $USER
    end
end
