#!/bin/bash

# Apple removed the `airport` binary in macOS 14.4, and CLI SSID lookup now
# requires Location Services permission (it returns "<redacted>" otherwise).
# So instead of the network name we report Wi-Fi *connection state*, read from
# the interface status — this needs no special tools or permissions.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Resolve the Wi-Fi hardware port's BSD interface (e.g. en0); fall back to en0.
WIFI_IF=$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')
[ -z "$WIFI_IF" ] && WIFI_IF="en0"

if ifconfig "$WIFI_IF" 2>/dev/null | grep -q "status: active"; then
  sketchybar --set wifi icon="$WIFI_CONNECTED" icon.color=0xff58d1fc
else
  sketchybar --set wifi icon="$WIFI_DISCONNECTED" icon.color="$GREY"
fi
