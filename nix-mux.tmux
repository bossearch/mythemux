#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source $SCRIPTS_PATH/themes.sh

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"

Highlight colors
tmux set -g mode-style "fg=${THEME[bgreen]},bg=${THEME[bblack]}"

tmux set -g message-style "bg=${THEME[blue]},fg=${THEME[background]}"
tmux set -g message-command-style "fg=${THEME[white]},bg=${THEME[black]}"

tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[ghturquoise]}"
tmux set -g pane-border-status off

tmux set -g status-style bg="${THEME[ghblack]}"
tmux set -g popup-border-style "fg=${THEME[ghturquoise]}"

HOSTNAME=$(hostname)
terminal_icon=""
active_terminal_icon=""
window_space=" "
window_number="#($SCRIPTS_PATH/custom-number.sh #I digital)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P digital)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P hsquare)"

### session name ###
tmux set -g status-left "#[fg=${THEME[bblack]},bg=${THEME[blue]},bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S#[nodim,fg=${THEME[black]}]@$HOSTNAME "

### windows ###
# focus
tmux set -g window-status-current-format "$RESET#[fg=${THEME[green]},bg=${THEME[ghsky]}] \
#{?#{==:#{pane_current_command},ssh},󰣀 ,$active_terminal_icon $window_space}\
#[fg=${THEME[blue]},bold,nodim]#W\
#[nobold]#{?window_zoomed_flag, $window_number.$zoom_number, $window_number.$custom_pane}\
#{?window_last_flag, , }"

#focused
tmux set -g window-status-format "$RESET#[fg=${THEME[foreground]},bg=${THEME[ghblack]}] \
#{?#{==:#{pane_current_command},ssh},󰣀 ,$terminal_icon $window_space}#W\
#[nobold,dim]#{?window_zoomed_flag, $zoom_number, $window_number.$custom_pane}\
#{?window_last_flag, , }"
