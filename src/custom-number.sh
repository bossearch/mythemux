#!/usr/bin/env bash

format_digital="🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹"
format_hsquare="󰎣󰎦󰎩󰎬󰎮󰎰󰎵󰎸󰎻󰎾"

ID=$1
FORMAT=${2:-none}

# Preserve leading whitespace for bash
format="$(eval echo \"\$format_${FORMAT}\")"

if [ -z "$format" ]; then
  echo "Invalid format: $FORMAT"
  exit 1
fi

for ((i = 0; i < ${#ID}; i++)); do
  DIGIT=${ID:i:1}
  echo -n "${format:DIGIT:1}"
done

