function telnet --argument ip port timeout
    if test -z "$timeout"
        set timeout 20s
    end
    timeout "$timeout" telnet.exe "$ip" "$port"
end