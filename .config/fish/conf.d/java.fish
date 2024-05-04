if type -q java
    set -x JAVA_HOME (dirname (dirname (readlink -f /usr/bin/java)))
end
