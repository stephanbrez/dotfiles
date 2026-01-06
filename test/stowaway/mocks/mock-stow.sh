#!/bin/bash

# Mock stow command for testing
# Logs all actions to a file instead of executing them

# Exit early if being sourced (not called as stow)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	return 0
fi

# If called with no arguments, it's probably a which check
if [[ $# -eq 0 ]]; then
	exit 0
fi

LOG_FILE="/tmp/stowaway-test/logs/stow.log"
echo "$(date): mock-stow called with: $*" >>"$LOG_FILE"

# Parse arguments to understand what stow would do
TARGET=""
COMMAND=""
PACKAGE=""

while [[ $# -gt 0 ]]; do
	case $1 in
	-t | --target)
		TARGET="$2"
		shift 2
		;;
	-S | --stow)
		COMMAND="stow"
		shift
		;;
	-R | --restow)
		COMMAND="restow"
		shift
		;;
	-D | --delete)
		COMMAND="delete"
		shift
		;;
	--adopt)
		COMMAND="${COMMAND}-adopt"
		shift
		;;
	-*)
		shift
		;;
	*)
		if [[ -z "$PACKAGE" ]]; then
			PACKAGE="$1"
		fi
		shift
		;;
	esac
done

echo "$(date): Would execute: stow $COMMAND $PACKAGE -t $TARGET" >>"$LOG_FILE"

exit 0
