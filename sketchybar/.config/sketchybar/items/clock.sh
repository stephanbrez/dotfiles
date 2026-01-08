#!/bin/sh

# Define clock
clock=(
    background.color="$BACKGROUND_1"
    background.border_color="$BAR_BORDER_COLOR"
    background.border_width=1
    update_freq=10
    icon=
    script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
           --set clock "${clock[@]}" \
