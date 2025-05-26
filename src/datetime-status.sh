#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

# Exit if in a graphical session (TTY fallback check)
if [[ -n "$DISPLAY" ]]; then
  exit 0
fi

date_string=" %d-%m-%Y"
time_string="%H:%M "
separator="❬ "

echo "$RESET#[fg=${THEME[blue]},bg=${THEME[ghsky]}]$date_string $separator$time_string"

