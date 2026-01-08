#!/bin/bash

# Test wrapper for stowaway-check script
# Sources mock functions and sets up test environment

echo "Running stowaway-check with args: $*" >&2

# Use the production stowaway-check script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_TO_RUN="$SCRIPT_DIR/../../bin/.local/bin/stowaway-check"

# Allow debug override if present
if [[ -f "$SCRIPT_DIR/stowaway-check-debug" ]]; then
	SCRIPT_TO_RUN="$SCRIPT_DIR/stowaway-check-debug"
fi

export PATH="$(dirname "$0")/mocks:$PATH"
exec "$SCRIPT_TO_RUN" "$@"
