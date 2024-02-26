set -x JAVA_HOME (dirname (readlink -f /usr/bin/java))
add-path PATH $JAVA_HOME
