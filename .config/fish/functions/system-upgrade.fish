function system-upgrade --argument-names release --description "A dnf system upgrade"
  set --local perm (sudo echo "y" || echo "n")

  if test "$perm" = "y"
    if ! dnf list | grep 'dnf-plugins-core' &> /dev/null
      sudo dnf install dnf-plugin-system-upgrade -y
    end
    sudo dnf --refresh upgrade -y
    if type -q nobara-sync
      sudo nobara-sync
    end
    if type -q wslpath
      set -xf DNF_SYSTEM_UPGRADE_NO_REBOOT 1
    end
    if sudo dnf system-upgrade download --releasever=$release -y
      set perm (sudo echo "y" || echo "n")
      while test "$perm" = "n"
        set perm (sudo echo "y" || echo "n")
      end
      # sudo dnf system-upgrade clean -y
      # sudo dnf clean packages -y
      sudo -E dnf system-upgrade reboot -y
      sudo -E dnf system-upgrade upgrade -y
    end
  end
end
