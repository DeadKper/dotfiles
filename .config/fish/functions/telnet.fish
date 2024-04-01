if type -q telnet.exe
    function telnet --argument ip port time
        if test (count $argv) -lt 2
            echo 'usage: telnet IP PORT <TIME>'
            return 1
        end
        if test -z "$time"
            timeout 5s telnet.exe "$ip" "$port"
            if test "$status" = 124
                timeout 25s telnet.exe "$ip" "$port"
                if test "$status" = 124
                    echo "Connection timed out 2 times, try again specifying connection timeout or 0 to disable it"
                end
            end
        else if test "$time" -eq 0
            telnet.exe "$ip" "$port"
        else
            timeout {$time}s telnet.exe "$ip" "$port"
            echo "Connection timed out, try again increasing connection timeout or 0 to disable it"
        end
    end
end

