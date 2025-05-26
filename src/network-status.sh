#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR"/themes.sh

declare -A NET_ICONS=(
  ["traffic_tx"]="#[fg=${THEME[bblue]}]\U000f06f6"
  ["traffic_rx"]="#[fg=${THEME[bgreen]}]\U000f06f4"
)

get_bandwidth() {
  netstat -ie | awk '
    match($0, /RX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, rx) { rx_sum += rx[2]; }
    match($0, /TX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, tx) { tx_sum += tx[2]; }
    END { print rx_sum, tx_sum }
  '
}

format_speed() {
  local value
  local bytes_per_sec=$1
  local unit="KB/s"
  value=$(awk "BEGIN { printf \"%.1f\", $bytes_per_sec / 1024 }")

  if (( $(echo "$value >= 1024" | bc -l) )); then
    value=$(awk "BEGIN { printf \"%.1f\", $value / 1024 }")
    unit="MB/s"
  fi

  if (( $(echo "$value >= 1024" | bc -l) )); then
    value=$(awk "BEGIN { printf \"%.1f\", $value / 1024 }")
    unit="GB/s"
  fi

  echo "${value}${unit}"
}

main() {
  local sleep_time
  sleep_time=$(tmux show-option -gqv "status-interval")
  local old_value
  old_value=$(tmux show-option -gqv "@network-bandwidth-previous-value")

  if [ -z "$sleep_time" ]; then sleep_time=5; fi

  if [ -z "$old_value" ] || [ "$old_value" == "-" ]; then
    tmux set-option -gq "@network-bandwidth-previous-value" "-"
    echo -n "Please wait..."
    return 0
  else
    local first_measure
    local second_measure
    local formatted
    read -ra first_measure <<< "$(get_bandwidth)"
    sleep "$sleep_time"
    read -ra second_measure <<< "$(get_bandwidth)"
    local download_speed=$(( (second_measure[0] - first_measure[0]) / sleep_time ))
    local upload_speed=$(( (second_measure[1] - first_measure[1]) / sleep_time ))
    formatted="↓$(format_speed $download_speed) • ↑$(format_speed $upload_speed)"
    tmux set-option -gq "@network-bandwidth-previous-value" "$formatted"
  fi

RX_SPEED="#[fg=${THEME[foreground]}]$(format_speed $download_speed)"
TX_SPEED="#[fg=${THEME[foreground]}]$(format_speed $upload_speed)"
displayed="#[bg=${THEME[ghblack]}]░ ${NET_ICONS[traffic_rx]} $RX_SPEED \
${NET_ICONS[traffic_tx]} $TX_SPEED "
echo -e "$displayed"
}

main
