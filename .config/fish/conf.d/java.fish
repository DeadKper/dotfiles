if test -z "$ENV_SET"
  set -xg JAVA_HOME "$(readlink -f /usr/bin/java | sed "s:/bin/java::")"
  add_path PATH "$JAVA_HOME/bin"
end