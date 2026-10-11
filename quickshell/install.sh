#!/usr/bin/env bash
set -euo pipefail
source_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
target="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control"
for command in qs python3; do
    if ! command -v "$command" >/dev/null; then
        printf 'Missing required command: %s\n' "$command" >&2
        exit 1
    fi
done
if [[ -e "$target" ]]; then
    if [[ "${1:-}" != "--update" ]]; then
        printf 'Already exists: %s\nRun the extracted installer with --update to back up and update it.\n' "$target" >&2
        exit 1
    fi
    if [[ "$source_dir" == "$(realpath -- "$target")" ]]; then
        printf 'Run --update from the newly extracted copy, not the installed folder.\n' >&2
        exit 1
    fi
    backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
    cp -R -- "$target" "$backup"
    cp -R -- "$source_dir/." "$target/"
    printf 'Updated. Previous configuration: %s\n' "$backup"
else
    mkdir -p -- "$(dirname -- "$target")"
    cp -R -- "$source_dir" "$target"
fi
printf 'Installed to %s\nStop your current notification daemon, then run: env QT_QUICK_CONTROLS_STYLE=Fusion qs -p "%s"\n' "$target" "$target"
