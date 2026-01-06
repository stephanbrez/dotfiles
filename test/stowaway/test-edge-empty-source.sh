#!/bin/bash

# Test script for edge case: empty source directory

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing edge case: empty source directory..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Create empty source directory
mkdir -p "$TEST_DIR/empty-source"

# Run the test
OUTPUT=$(timeout 5 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/empty-source" "$TEST_DIR/target" <<<"" 2>&1)

echo "🔍 Checking results..."

# Check that the script handles empty directory gracefully
if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Empty source test passed - script completed successfully"
else
	echo "❌ Empty source test failed - script did not complete"
	echo "Output: $OUTPUT"
	exit 1
fi

# Check that no stow commands were executed
if [[ ! -f "$TEST_DIR/logs/stow.log" ]] || [[ ! -s "$TEST_DIR/logs/stow.log" ]]; then
	echo "✅ Empty source test passed - no stow commands executed"
else
	echo "❌ Empty source test failed - unexpected stow commands"
	cat "$TEST_DIR/logs/stow.log"
	exit 1
fi

echo "🎉 Empty source directory test completed successfully!"
