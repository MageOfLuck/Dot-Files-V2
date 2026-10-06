#!/usr/bin/env bash
GROUP="$1"
hyprctl dispatch "hl.dsp.focus({ workspace = ${GROUP} })"
hyprctl dispatch "hl.dsp.focus({ workspace = $((GROUP + 3)) })"
hyprctl dispatch "hl.dsp.focus({ workspace = $((GROUP + 6)) })"