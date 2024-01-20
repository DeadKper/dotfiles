if test -z "$ENV_SET"
  set -xg JAVA_HOME "$(readlink -f /usr/bin/java | sed "s:/bin/java::")"
  fish_add_path "$JAVA_HOME/bin"
end
