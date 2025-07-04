#!/usr/bin/env bash
# Modified from: Lógico Software's Tokyo Night tmux theme
# Original: https://github.com/logico-dev/tokyo-night-tmux
# License: MIT

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source "$HOME/.config/tmux/theme.sh"

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"

# options
tmux set -g message-command-style "fg=${THEME[white]},bg=${THEME[black]}"
tmux set -g message-style "bg=${THEME[blue]},fg=${THEME[background]}"
tmux set -g mode-style "fg=${THEME[bgreen]},bg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[ghturquoise]}"
tmux set -g pane-border-status off
tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g popup-border-style "fg=${THEME[ghturquoise]}"
tmux set -g status-left-length 80
tmux set -g status-right-length 150
tmux set -g status-style bg="${THEME[black]}"

HOSTNAME=$(hostname)
terminal_icon=""
active_terminal_icon=""

# modules
window_number="#($SCRIPTS_PATH/custom-number.sh #I none)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P none)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P none)"
datetime="$("$SCRIPTS_PATH"/datetime-status.sh)"
music="#($SCRIPTS_PATH/music-status.sh)"
network="#($SCRIPTS_PATH/network-status.sh)"
wbgit="#($SCRIPTS_PATH/wbgit-status.sh)"

### LEFT ###
### session name ###
tmux set -g status-left "#[fg=${THEME[black]},bg=${THEME[blue]},bold] \
#{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S#[nodim,fg=${THEME[bblack]}]@$HOSTNAME "

### windows ###
# focus
tmux set -g window-status-current-format "$RESET#[fg=${THEME[green]},bg=${THEME[ghsky]}] \
#{?#{==:#{pane_current_command},ssh},󰣀  ,$active_terminal_icon  }\
#[fg=${THEME[blue]},bold,nodim]#W $window_number.\
#{?window_zoomed_flag,#[bold]$zoom_number,#[nobold,dim]$custom_pane} "

# unfocus
tmux set -g window-status-format "$RESET#[fg=${THEME[foreground]},bg=${THEME[black]}] \
#{?#{==:#{pane_current_command},ssh},󰣀  ,$terminal_icon  }#W $window_number.\
#{?window_zoomed_flag,#[bold]$zoom_number,#[nobold,dim]$custom_pane} "

### RIGHT ###
tmux set -g status-right "$network$wbgit$music$datetime"
tmux set -g window-status-separator ""
