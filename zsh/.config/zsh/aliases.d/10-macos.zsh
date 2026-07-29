# macOS-specific aliases

# Update packages
alias update="brew update && brew upgrade"

# Open a new Ghostty window running glow on a file: glowin README.md
# A function, not an alias: open-launched Ghostty runs the command via a login
# shell that cd's to $HOME, so we pass an absolute file path (${1:A}). Keep the
# command bare (glow, not its full path); the login shell already has our PATH.
# Use glow's pager (-p) so the window stays open until you quit — otherwise glow
# renders and exits and Ghostty closes the window instantly.
glowin() {
  open -na Ghostty.app --args -e glow -p "${1:A}"
}

# Ghostty CLI lives inside the app bundle; expose it for +list-themes etc.
alias ghostty='/Applications/Ghostty.app/Contents/MacOS/ghostty'
