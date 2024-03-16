if type -q java
    set -x JAVA_HOME (dirname (dirname (readlink -f /usr/bin/java)))
    add-path PATH $JAVA_HOME
end
