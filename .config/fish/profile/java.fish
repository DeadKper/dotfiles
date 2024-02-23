set -x JAVA_HOME (dirname (readlink -f /usr/bin/java))
fish_add_path $JAVA_HOME
