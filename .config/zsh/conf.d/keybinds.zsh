backward-kill-word-to-space() {
  local WORDCHARS="|°¬!\"#\$%&/()='?\\¿¡´¨+*~{}[]^\`,;.:-_<>@"
  zle backward-kill-word
}

zle -N backward-kill-word-to-space
bindkey '^W' backward-kill-word-to-space
