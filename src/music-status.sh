#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$HOME/.config/tmux/theme.sh"

# Exit if not in a graphical session (TTY fallback check)
if [[ -z "$DISPLAY" ]]; then
  exit 0
fi

ACCENT_COLOR="${THEME[base0D]}"
BG_COLOR="${THEME[base00]}"
BG_BAR="${THEME[base00]}"
TIME_COLOR="${THEME[base0D]}"

MAX_TITLE_WIDTH=$(($(tmux display -p '#{window_width}' 2>/dev/null || echo 120) / 4))

# playerctl
PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{artist}} - {{title}};{{xesam:url}}" | grep -m1 "Playing")
STATUS="playing"

# There is no playing media, check for paused media
if [ -z "$PLAYER_STATUS" ]; then
  PLAYER_STATUS=$(playerctl -a metadata --format "{{status}};{{mpris:length}};{{position}};{{artist}} - {{title}};{{xesam:url}}" | grep -m1 "Paused")
  STATUS="paused"
fi

DURATION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=2)
POSITION=$(echo "$PLAYER_STATUS" | cut -d';' --fields=3)
TITLE=$(echo "$PLAYER_STATUS" | cut -d';' --fields=4)
URL=$(echo "$PLAYER_STATUS" | cut -d';' --fields=5 | cut -d'.' -f2)

# Convert position and duration to seconds from microseconds
DURATION=$((DURATION / 1000000))
POSITION=$((POSITION / 1000000))

if [ "$DURATION" -eq 0 ]; then
  DURATION=-1
  POSITION=0
fi

# Calculate the progress bar for sane durations
if [ -n "$DURATION" ] && [ -n "$POSITION" ] && [ "$DURATION" -gt 0 ] && [ "$DURATION" != "$POSITION" ]; then
  if [ "$DURATION" -lt 3600 ]; then
    TIME="[$(date -d@$POSITION -u +%M:%S) / $(date -d@$DURATION -u +%M:%S)]"
    BUFFER=23
  else
    TIME="[$(date -d@$POSITION -u +%H:%M:%S) / $(date -d@$DURATION -u +%H:%M:%S)]"
    BUFFER=29
  fi
elif [ "$DURATION" = "$POSITION" ]; then
  TIME="[󰐾 LIVE]"
  BUFFER=16
else
  TIME="[--:--]"
  BUFFER=15
fi

if [ -n "$TITLE" ]; then
  if [ "$STATUS" = "playing" ]; then
    if [ "$URL" = "youtube" ]; then
      PLAY_STATE="░  $OUTPUT"
    elif [ "$URL" = "twitch" ]; then
      PLAY_STATE="░  $OUTPUT"
    elif [ "$URL" = "spotify" ]; then
      PLAY_STATE="░  $OUTPUT"
    elif [ "$URL" = "idlixku" ] || [ "$URL" = "netflix" ]; then
      PLAY_STATE="░ 󰝆 $OUTPUT"
    else
      PLAY_STATE="░  $OUTPUT"
    fi
  else
    PLAY_STATE="░ 󰏤 $OUTPUT"
  fi
  OUTPUT="$PLAY_STATE $TITLE"

  if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH ]; then
    OUTPUT="$PLAY_STATE ${TITLE:0:$MAX_TITLE_WIDTH-$BUFFER}…"
  fi
else
  OUTPUT=''
fi

if [ -z "$OUTPUT" ]; then
  echo ""
else
  OUT="$OUTPUT $TIME "
  ONLY_OUT="$OUTPUT "
  TIME_INDEX=${#ONLY_OUT}
  OUTPUT_LENGTH=${#OUT}
  PERCENT=$((POSITION * 100 / DURATION))
  PROGRESS=$((OUTPUT_LENGTH * PERCENT / 100))
  O="$OUTPUT"

  if [ $PROGRESS -le "$TIME_INDEX" ]; then
    echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:PROGRESS}#[fg=$ACCENT_COLOR,bg=$BG_BAR]${O:PROGRESS:TIME_INDEX} #[fg=$TIME_COLOR,bg=$BG_BAR]$TIME "
  else
    DIFF=$((PROGRESS - TIME_INDEX))
    echo "#[nobold,fg=$BG_COLOR,bg=$ACCENT_COLOR]${O:0:TIME_INDEX} #[fg=$BG_BAR,bg=$ACCENT_COLOR]${OUT:TIME_INDEX:DIFF}#[fg=$TIME_COLOR,bg=$BG_BAR]${OUT:PROGRESS}"
  fi
fi
