if test -z "$ENV_SET"
  set -x JAVA_HOME "$(readlink -f /usr/bin/java | sed "s:/bin/java::")"
  fish_add_path "$JAVA_HOME/bin"
end
