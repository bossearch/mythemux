#!/usr/bin/env bash

declare -A THEME=(
  ["background"]="#1A1B26" #
  ["foreground"]="#a9b1d6" # #network #wbgit
  ["black"]="#414868" #
  ["blue"]="#7aa2f7" # #date #music
  ["green"]="#73daca" #
  ["white"]="#c0caf5" #
  ["bblack"]="#2A2F41" #
  ["bblue"]="#7aa2f7" # #network
  ["bgreen"]="#41a6b5" # #network
  ['ghgreen']="#3fb950" #wbgit
  ['ghred']="#d73a4a" #wbgit
  ['ghyellow']="#d29922" #wbgit
  ['ghsky']="#3B4261" # #date
  ['ghturquoise']="#27a1b9" #
  ['ghblack']="#16161E" # #network #music #wbgit
)

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
