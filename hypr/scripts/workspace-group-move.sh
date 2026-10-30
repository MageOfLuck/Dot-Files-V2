#!/usr/bin/env bash

GROUP="$1"

# Get monitor ID of active window
MON_ID=$(hyprctl activewindow -j | jq -r '.monitor')

# Get monitor name
MON_NAME=$(hyprctl monitors -j | jq -r \
    --argjson id "$MON_ID" \
    '.[] | select(.id == $id) | .name')

# Calculate workspace
case "$MON_NAME" in
    DP-2)
        TARGET=$GROUP
        ;;
    HDMI-A-1)
        TARGET=$((GROUP + 3))
        ;;
    DP-1)
        TARGET=$((GROUP + 6))
        ;;
    *)
        echo "Unknown monitor: $MON_NAME" >&2
        exit 1
        ;;
esac

# Debug output
echo "Monitor: $MON_NAME"
echo "Target workspace: $TARGET"

# Hyprland 0.57 Lua dispatcher
hyprctl dispatch "hl.dsp.window.move({ workspace = \"${TARGET}\" })"