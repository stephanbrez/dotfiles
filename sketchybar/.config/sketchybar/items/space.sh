#!/bin/bash

# Get all relevant commands via aerospace --help
# aerospace list-workspaces --all (get all workspaces: 1 2 3 4 5 6 7 8 9 10)
# aerospace list-windows --workspace 1 (get windows in workspace 1)
# Example output:
# 11881 | Cursor | Command.ts — tcpro
# 14519 | Cursor | space.sh — dotfiles

backgroundBorderWidth=1

# Map aerospace monitor-id to sketchybar display id
map_monitor_to_display() {
	case "$1" in
		1) echo "3" ;;  # PA247CV: aerospace monitor 1 -> sketchybar display 3
		2) echo "2" ;;  # LG SDQHD: aerospace monitor 2 -> sketchybar display 2
		3) echo "1" ;;  # Built-in: aerospace monitor 3 -> sketchybar display 1
		*) echo "1" ;;
	esac
}

# Aerospace workspaces 1 2 3 4 5 6 7 8 9 10
for sid in $(aerospace list-workspaces --all); do
	aerospace_monitor=$(aerospace list-windows --workspace "$sid" --format "%{monitor-id}")

	if [ -z "$aerospace_monitor" ]; then
		aerospace_monitor="1"
	fi

	monitor=$(map_monitor_to_display "$aerospace_monitor")

	if [ "$sid" = "1" ]; then
		icon=" "
		iconColor="$GREEN"
	elif [ "$sid" = "2" ]; then
		icon=" "
		iconColor="$BLUE"
	elif [ "$sid" = "3" ]; then
		icon=" "
		iconColor="$YELLOW"
	elif [ "$sid" = "4" ]; then
		icon="󰹕"
		iconColor="$ORANGE"
	elif [ "$sid" = "5" ]; then
		icon="󰈰"
		iconColor="$RED"
	elif [ "$sid" = "6" ]; then
		icon=" "
	elif [ "$sid" = "7" ]; then
		icon="󰺻"
	elif [ "$sid" = "8" ]; then
		icon=""
	elif [ "$sid" = "9" ]; then
		icon="💬"
	else
		icon=""
		iconColor="$ICON_COLOR"
		backgroundBorderWidth=0
	fi

	sketchybar --add item space."$sid" left \
		--subscribe space."$sid" display_change system_woke mouse.entered mouse.exited \
		--set space."$sid" \
		display="$monitor" \
		padding_left=2 \
		padding_right=2 \
		icon="$icon" \
		icon.padding_left=6 \
		icon.padding_right=6 \
		icon.color="$iconColor" \
		background.color="$BACKGROUND_1" \
		background.drawing=on \
		background.corner_radius=5 \
		background.height=25 \
		background.border_width="$backgroundBorderWidth" \
		background.border_color="$BAR_BORDER_COLOR" \
		label.padding_right=9 \
		label.drawing=on \
		click_script="aerospace workspace $sid" \
		script="$PLUGIN_DIR/aerospace.sh $sid"
done

# Add a hidden item that listens for workspace changes and refreshes all spaces
sketchybar --add item aerospace_refresh left \
	--set aerospace_refresh \
	drawing=off \
	script="$PLUGIN_DIR/aerospace_refresh.sh" \
	--subscribe aerospace_refresh aerospace_workspace_change
