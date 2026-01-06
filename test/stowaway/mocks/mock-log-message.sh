#!/bin/bash

# Mock log-message function for testing
# Captures all log messages to files for verification

LOG_DIR="/tmp/stowaway-test/logs"
mkdir -p "$LOG_DIR"

log-message() {
	echo "MOCK-LOG: Called with level=$1, message=$2, force=$3" >&2
	local level="$1"
	local message="$2"
	local force="${3:-false}"

	# Log to file
	echo "$(date): [$level] $message" >>"$LOG_DIR/log-message.log"

	# Also log to level-specific files
	echo "$(date): $message" >>"$LOG_DIR/${level,,}.log"

	# Print to stdout if force is true or if verbose mode
	if [[ "$force" == "true" ]] || [[ "${VERBOSE:-false}" == "true" ]]; then
		case "$level" in
		"DEBUG") echo "🐛 $message" ;;
		"INFO") echo "ℹ️  $message" ;;
		"WARNING") echo "⚠️  $message" ;;
		"SUCCESS") echo "✅ $message" ;;
		"ERROR") echo "❌ $message" ;;
		*) echo "$message" ;;
		esac
	fi
}

fail() {
	local message="$1"
	echo "$(date): FAIL: $message" >>"$LOG_DIR/error.log"
	printf "\r\033[2K  [ \033[01;31mFAIL\033[0m ] %s\n" "$message"
	echo ''
	exit 1
}
