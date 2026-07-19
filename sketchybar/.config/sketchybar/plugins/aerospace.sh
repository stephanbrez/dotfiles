#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

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

# Resolve the sketchybar display from aerospace's AppKit NSScreen id, which
# lines up 1:1 with sketchybar's `display` number and follows monitors as they
# are plugged/unplugged/rearranged (no hardcoded monitor map). Not in the JSON,
# so query it separately.
monitor=$(aerospace list-windows --workspace "$1" --format "%{monitor-appkit-nsscreen-screens-id}" | head -1)

if [ -z "$monitor" ]; then
  monitor="1"
fi


# Update the space with current apps and monitor
sketchybar --set "$NAME" \
  display="$monitor" \
  drawing=on \
  label="$icons" \
  icon.font.size=14

