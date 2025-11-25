#!/usr/bin/env bash

source "$HOME/.config/tmux/theme.sh"

declare -A NET_ICONS=(
  ["traffic_tx"]="#[fg=${THEME[bblue]}]\U000f06f6"
  ["traffic_rx"]="#[fg=${THEME[bgreen]}]\U000f06f4"
)

get_default_gateway() {
  ip route | awk '/default/ {print $3; exit}'
}

check_internet() {
  local gw
  gw=$(get_default_gateway) || return 1
  ping -q -c 1 -W 2 "$gw" >/dev/null 2>&1
}

get_interface() {
  ip route | awk '
    /default/ { print $5; exit }
    /src/     { print $3; exit }
  '
}

get_bandwidth() {
  local iface rx tx
  iface=$(get_interface)
  read -r rx <"/sys/class/net/$iface/statistics/rx_bytes"
  read -r tx <"/sys/class/net/$iface/statistics/tx_bytes"
  printf "%s %s\n" "$rx" "$tx"
}

format_speed() {
  awk -v b="$1" '
    BEGIN {
      if (b < 1048576) { printf "%.1fKB/s", b/1024; exit }
      if (b < 1073741824) { printf "%.1fMB/s", b/1048576; exit }
      printf "%.1fGB/s", b/1073741824
    }
  '
}

main() {
  local sleep_time
  sleep_time=$(tmux show-option -gqv "status-interval")
  [ -z "$sleep_time" ] && sleep_time=5

  if ! check_internet; then
    echo -e "#[fg=${THEME[ghred]},bg=${THEME[black]}]░ Disconnected   "
    return 0
  fi

  read -r rx1 tx1 < <(get_bandwidth)
  sleep "$sleep_time"
  read -r rx2 tx2 < <(get_bandwidth)

  local download_speed=$(((rx2 - rx1) / sleep_time))
  local upload_speed=$(((tx2 - tx1) / sleep_time))

  RX_SPEED="#[fg=${THEME[foreground]}]$(format_speed "$download_speed")"
  TX_SPEED="#[fg=${THEME[foreground]}]$(format_speed "$upload_speed")"

  echo -e "#[bg=${THEME[black]}]░ ${NET_ICONS[traffic_rx]} $RX_SPEED ${NET_ICONS[traffic_tx]} $TX_SPEED "
}

main
