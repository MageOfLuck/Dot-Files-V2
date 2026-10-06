#!/usr/bin/env bash
GAME_CLASS="steam_app_2767030"

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
while read -r line; do
    case "$line" in
        activewindow\>\>*)
            class="${line#activewindow>>}"
            class="${class%%,*}"
            if [[ "$class" == "$GAME_CLASS" ]]; then
                hyprctl dispatch submap reset      # side buttons pass straight to Rivals
            else
                hyprctl dispatch submap desktop    # your drag/resize binds active
            fi
            ;;
    esac
done
