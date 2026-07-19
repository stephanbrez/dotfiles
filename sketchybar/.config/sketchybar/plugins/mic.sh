#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/mic.sh

# https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1216899

source "$CONFIG_DIR/colors.sh"

# The mic device is read via SwitchAudioSource (brew install switchaudio-osx).
# Degrade gracefully if it isn't on PATH (e.g. launched as a service without
# Homebrew in PATH, or not installed) instead of erroring on every update.
if ! command -v SwitchAudioSource >/dev/null 2>&1; then
  sketchybar --set mic icon= icon.color="$GREY"
  exit 0
fi

# Attempt to get the current input device name
MIC_NAME=$(SwitchAudioSource -t input -c)
# I just want the first word, in case it's too long
MIC_NAME=$(echo $MIC_NAME | awk '{print $1}')

# When no microphone is connected, SwitchAudioSource gives me back random
# characters and sketchybar shows "Warning: Malformed UTF-8 string"
# Validate MIC_NAME as UTF-8, replace invalid sequences with a '?', then compare with original
VALIDATED_MIC_NAME=$(echo "$MIC_NAME" | iconv -f UTF-8 -t UTF-8//IGNORE)

# Get the current microphone volume
MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')

# Check if MIC_NAME is not meaningful
# Remove MIC_NAME from label
if [[ "$MIC_NAME" != "$VALIDATED_MIC_NAME" || -z "$MIC_NAME" ]]; then
  sketchybar -m --set mic label="" icon= icon.color=$YELLOW label.color=$YELLOW
else
  if [[ $MIC_VOLUME -eq 0 ]]; then
    sketchybar -m --set mic label="" icon= icon.color=$RED label.color=$RED
  elif [[ $MIC_VOLUME -gt 0 && $MIC_VOLUME -lt 100 ]]; then
    sketchybar -m --set mic label="" icon= icon.color=$ORANGE label.color=$ORANGE
  elif [[ $MIC_VOLUME -eq 100 ]]; then
    sketchybar -m --set mic label="" icon= icon.color=$WHITE label.color=$WHITE
  fi
fi
