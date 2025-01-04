[[ -o interactive ]] || return

typeset -A ZSH_HIGHLIGHT_STYLES

local bg0=0b0b0b
local bg1=161616
local bg2=262626
local bg3=292929

local fg0=e0e0e0
local fg1=8d8d8d
local fg2=6f6f6f

local blue=78a9ff
local green=42be65
local lavender=be95ff
local magenta=ee5396
local pink=ff7eb6
local verdigris=08bdba
local gray=adb5bd
local sky=99daff
local cyan=25cac8

ZSH_HIGHLIGHT_STYLES[precommand]="fg=#$sky"
ZSH_HIGHLIGHT_STYLES[command]="fg=#$pink"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#$pink"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#$pink"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=#$pink"

ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#$lavender"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=#$lavender"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#$lavender"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=#$lavender"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=#$lavender"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="fg=#$lavender"

ZSH_HIGHLIGHT_STYLES[comment]="fg=#$fg2"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#$blue"

ZSH_HIGHLIGHT_STYLES[redirection]="fg=#$green"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=#$green"

ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=#$sky"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#$fg2,underline"
export ZSH_HIGHLIGHT_STYLES
