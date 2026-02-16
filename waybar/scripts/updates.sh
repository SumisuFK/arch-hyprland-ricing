#!/bin/bash

DB="/tmp/checkup-db-${UID}-$$"
trap 'rm -rf "$DB"' EXIT


updates=$(CHECKUPDATES_DB="$DB" checkupdates 2>/dev/null | wc -l)

if [ "$updates" -gt 0 ]; then
    echo "󰏗  $updates"
else
    echo ""
fi
