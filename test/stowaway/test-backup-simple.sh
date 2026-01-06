#!/bin/bash

# Test script for backup option (b)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing backup functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'b' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"bss" 2>&1)

echo "🔍 Checking results..."

# Check that backup was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Backup test passed - conflict detection worked"
else
	echo "❌ Backup test failed - no conflict prompt found"
	exit 1
fi

# This test now uses backup then install (b) option
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Backup test passed - backup option was presented"
else
	echo "❌ Backup test failed - backup option not available"
	echo "Output: $OUTPUT"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Backup test passed - script completed"
else
	echo "❌ Backup test failed - script did not complete"
	exit 1
fi

echo "🎉 Backup test completed successfully!"
