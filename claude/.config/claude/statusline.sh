#!/bin/bash
input=$(cat)
dir=$(basename "$(pwd)")
time=$(date +%H:%M)
user=$(whoami)
hostname=$(hostname)
git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
model=$(echo "$input" | jq -r '.model.display_name')

# Color codes
orange='\033[38;5;214m'
blue='\033[34m'
grey='\033[90m'
reset='\033[0m'

if [ -n "$git_branch" ]; then
	printf " 🤖 ${orange}%s${reset}  👤 ${blue}%s${reset}  💻 %s  📁 %s  🌿 ${grey}%s${reset}" "$model" "$user" "$hostname" "$dir" "$git_branch"
else
	printf " 🤖 ${orange}%s${reset}  👤 ${blue}%s${reset}  💻 %s  📁 %s" "$model" "$user" "$hostname" "$dir"
fi
