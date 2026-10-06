#!/usr/bin/env bash
GROUP="$1"
MON_ID=$(hyprctl activewindow -j | jq -r '.monitor')

case "$MON_ID" in
  0) TARGET=$GROUP ;;
  1) TARGET=$((GROUP + 3)) ;;
  2) TARGET=$((GROUP + 6)) ;;
esac

hyprctl dispatch "hl.dsp.window.move({ workspace = ${TARGET} })"