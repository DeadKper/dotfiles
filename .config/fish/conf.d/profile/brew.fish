if not type -q brew
  set -l brew_paths /home/linuxbrew/.linuxbrew/bin /opt/homebrew/bin /usr/local/bin /usr/bin /bin /home/linuxbrew/.linuxbrew/sbin /opt/homebrew/sbin /usr/local/sbin /usr/sbin /sbin

  for brew_path in $brew_paths
    if test -f $brew_path/brew
      eval ($brew_path/brew shellenv)
      break
    end
  end
end
