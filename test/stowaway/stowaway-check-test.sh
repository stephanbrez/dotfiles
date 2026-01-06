#!/bin/bash

# Test wrapper for stowaway-check script
# Sources mock functions and sets up test environment

echo "Running stowaway-check with args: $*" >&2

SCRIPT_TO_RUN="$(dirname "$0")/stowaway-check"
if [[ -f "$(dirname "$0")/stowaway-check-debug" ]]; then
	SCRIPT_TO_RUN="$(dirname "$0")/stowaway-check-debug"
fi

export PATH="$(dirname "$0")/mocks:$PATH"
exec "$SCRIPT_TO_RUN" "$@"
