#!/usr/bin/env bash

# This script updates ALL spaces when workspace changes
source "$CONFIG_DIR/colors.sh"

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Update all workspaces
for sid in $(aerospace list-workspaces --all); do
  if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
    # Focused workspace - pink label
    sketchybar --set space."$sid" label.color="$PINK"
  else
    # Unfocused workspace - white label
    sketchybar --set space."$sid" label.color="$PURE_WHITE"
  fi
done
