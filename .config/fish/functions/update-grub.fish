function update-grub

  if type -q grub-mkconfig
    set grub grub
  else
    set grub grub2
  end

  eval "sudo $grub-mkconfig -o /boot/$grub/grub.cfg $argv"; 
end
