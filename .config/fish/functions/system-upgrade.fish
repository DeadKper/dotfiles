function system-upgrade --argument-names release --description "A dnf system upgrade"
  sudo dnf install dnf-plugin-system-upgrade
  sudo dnf system-upgrade download --releasever=$release
  sudo dnf system-upgrade reboot
end