#!/bin/bash

# Test wrapper for stowaway-check script
# Sources mock functions and sets up test environment

echo "Running stowaway-check with args: $*" >&2

# Run the actual stowaway-check script (use debug version if it exists)
SCRIPT_TO_RUN="$(dirname "$0")/stowaway-check"
if [[ -f "$(dirname "$0")/stowaway-check-debug" ]]; then
	SCRIPT_TO_RUN="$(dirname "$0")/stowaway-check-debug"
fi
exec "$SCRIPT_TO_RUN" "$@"
