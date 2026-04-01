#!/usr/bin/env bash
# Modified from: Lógico Software's Tokyo Night tmux theme
# Original: https://github.com/logico-dev/tokyo-night-tmux
# License: MIT

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

# shellcheck source=/dev/null
source "$HOME/.config/tmux/theme.sh"

RESET="#[fg=${THEME[base05]},bg=${THEME[base01]},nobold,noitalics,nounderscore,nodim]"

# options
tmux set -g message-command-style "fg=${THEME[base07]},bg=${THEME[base00]}"
tmux set -g message-style "bg=${THEME[base0D]},fg=${THEME[base01]}"
tmux set -g mode-style "fg=${THEME[base0F]},bg=${THEME[base03]}"
tmux set -g pane-active-border-style "fg=${THEME[base0F]}"
tmux set -g pane-border-status off
tmux set -g pane-border-style "fg=${THEME[base03]}"
tmux set -g popup-border-style "fg=${THEME[base0F]}"
tmux set -g status-left-length 80
tmux set -g status-right-length 150
tmux set -g status-style bg="${THEME[base00]}"

HOSTNAME=$(hostname)
terminal_icon=""
active_terminal_icon=""

# modules
datetime="$("$SCRIPTS_PATH"/datetime-status.sh)"
music="#($SCRIPTS_PATH/music-status.sh)"
network="#($SCRIPTS_PATH/network-status.sh)"
git="#($SCRIPTS_PATH/git-status.sh #{pane_current_path} &)"

### LEFT ###
### session name ###
tmux set -g status-left "#[fg=${THEME[base00]},bg=${THEME[base0D]},bold] \
#{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S#[nodim,fg=${THEME[base03]}]@$HOSTNAME "

### windows ###
# focus
tmux set -g window-status-current-format "$RESET#[fg=${THEME[base0B]},bg=${THEME[base02]}] \
#{?#{==:#{pane_current_command},ssh},󰣀  ,$active_terminal_icon  }\
#[fg=${THEME[base0D]},bold,nodim]#W #I.\
#{?window_zoomed_flag,#[bold]#P,#[nobold]#[dim]#P} "

# unfocus
tmux set -g window-status-format "$RESET#[fg=${THEME[base05]},bg=${THEME[base00]}] \
#{?#{==:#{pane_current_command},ssh},󰣀  ,$terminal_icon  }#W #I.\
#{?window_zoomed_flag,#[bold]#P,#[nobold]#[dim]#P} "

### RIGHT ###
tmux set -g status-right "$git$network$music$datetime"
tmux set -g window-status-separator ""
