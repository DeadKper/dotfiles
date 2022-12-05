function dnf-update --wraps='sudo dnf update --best --allowerasing -y' --description 'alias dnf-update=sudo dnf update --best --allowerasing -y'
  sudo dnf update --best --allowerasing -y; 
end
