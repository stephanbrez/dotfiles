#!/bin/bash

# Basic test runner for stowaway-check

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Starting stowaway-check tests..."

# Clean up previous test run
rm -rf "$TEST_DIR/logs"
mkdir -p "$TEST_DIR/logs"

echo "📋 Running skip test..."
"$SCRIPT_DIR/expect-scripts/test-skip.exp"

echo "🔍 Checking results..."

# Check that skip was logged
if grep -q "Skipping" "$TEST_DIR/logs/info.log"; then
	echo "✅ Skip test passed - skip action was logged"
else
	echo "❌ Skip test failed - skip action not found in logs"
	echo "Log contents:"
	cat "$TEST_DIR/logs/info.log"
	exit 1
fi

# Check that no stow command was executed
if [[ ! -f "$TEST_DIR/logs/stow.log" ]] || ! grep -q "Would execute" "$TEST_DIR/logs/stow.log"; then
	echo "✅ Skip test passed - no stow command executed"
else
	echo "❌ Skip test failed - stow command was executed"
	cat "$TEST_DIR/logs/stow.log"
	exit 1
fi

echo "🎉 Basic skip test completed successfully!"
