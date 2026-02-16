#!/bin/bash

set -euo pipefail

DB="/tmp/checkup-db-${UID}-$$"
trap 'rm -rf "$DB"' EXIT

get_updates() {
  CHECKUPDATES_DB="$DB" /usr/bin/checkupdates 2>/dev/null || true
}

while true; do
  UPDATES="$(get_updates)"

  if [[ -z "$UPDATES" ]]; then
    notify-send "No updates"
    exit 0
  fi

  CHOICE="$(printf "Update all\n%s\n" "$UPDATES" | rofi -dmenu -p "Updates" -theme ~/.config/rofi/config.rasi)"
  [[ -z "$CHOICE" ]] && exit 0

  if [[ "$CHOICE" == "Update all" ]]; then
    kitty -e sudo pacman -Syu
  else
    PKG="$(awk '{print $1}' <<< "$CHOICE")"
    kitty -e sudo pacman -S "$PKG"
  fi

done
[FfmpegThumbnailer]
Disabled=false
Priority=2
Locations=
Excludes=
MaxFileSize=0