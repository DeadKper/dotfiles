if type -q telnet.exe
    function telnet --argument ip port time
        if test (count $argv) -lt 2
            echo 'usage: telnet IP PORT <TIME>'
            return 1
        end
        if test -z "$time" -o "$time" -eq 0
            telnet.exe "$ip" "$port"
        else
            timeout {$time}s telnet.exe "$ip" "$port"
        end
    end
end
