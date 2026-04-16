#!/usr/bin/env bash

export GTK_THEME=Orchis-Dark

if pgrep -f "uv run hyprmod" > /dev/null 2>&1; then
    pkill -f "uv run hyprmod"
else
    cd "$HOME/hyprmod" || exit 1
    /usr/bin/uv run hyprmod > /dev/null 2>&1 &
fi