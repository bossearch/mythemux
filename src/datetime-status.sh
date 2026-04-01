#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$HOME/.config/tmux/theme.sh"

# Exit if in a graphical session (TTY fallback check)
if [[ -n "$DISPLAY" ]]; then
  exit 0
fi

date_string=" %d-%m-%Y"
time_string="%H:%M "
separator="❬ "

echo "$RESET#[fg=${THEME[base0D]},bg=${THEME[base02]}]$date_string $separator$time_string"
