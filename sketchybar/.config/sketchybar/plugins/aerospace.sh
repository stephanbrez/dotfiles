#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

# Map aerospace monitor-id to sketchybar display id
map_monitor_to_display() {
	case "$1" in
		1) echo "3" ;;  # PA247CV: aerospace monitor 1 -> sketchybar display 3
		2) echo "2" ;;  # LG SDQHD: aerospace monitor 2 -> sketchybar display 2
		3) echo "1" ;;  # Built-in: aerospace monitor 3 -> sketchybar display 1
		*) echo "1" ;;
	esac
}

# if [ "$SENDER" == "mouse.entered" ]; then
#   if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     exit 0
#   fi
#   sketchybar --set "$NAME" \
#     background.drawing=on \
#     label.color="$LABEL_COLOR" \
#     background.color="$PURE_BLACK"
#   exit 0
# fi

# if [ "$SENDER" == "mouse.exited" ]; then
#   if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#     exit 0
#   fi
#   sketchybar --set "$NAME" \
#     background.drawing=off \
#     label.color="$LABEL_COLOR" \
#     background.color="$PURE_BLACK"
#   exit 0
# fi

icons=""

APPS_INFO=$(aerospace list-windows --workspace "$1" --json)

# Check if workspace is empty
WINDOW_COUNT=$(echo "$APPS_INFO" | jq '. | length')

if [ "$WINDOW_COUNT" -eq 0 ]; then
  # Hide empty workspace
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

IFS=$'\n'
for sid in $(echo "$APPS_INFO" | jq -r '.[]["app-name"]'); do
  # If $icons doesn't contain $sid, add it to $icons
  if [[ ! "$icons" =~ $sid ]]; then
    icons+=$sid
    icons+=" "
  fi
done

# Get monitor id from aerospace (not available in JSON, need separate query)
aerospace_monitor=$(aerospace list-windows --workspace "$1" --format "%{monitor-id}" | head -1)

if [ -n "$aerospace_monitor" ]; then
  monitor=$(map_monitor_to_display "$aerospace_monitor")
else
  monitor="1"
fi


# Update the space with current apps and monitor
sketchybar --set "$NAME" \
  display="$monitor" \
  drawing=on \
  label="$icons" \
  icon.font.size=14

