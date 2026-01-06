#!/bin/bash

# Test script for overwrite option (o)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing overwrite functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'o' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"oss" 2>&1)

echo "🔍 Checking results..."

# Check that overwrite was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Overwrite test passed - conflict detection worked"
else
	echo "❌ Overwrite test failed - no conflict prompt found"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Overwrite test passed - script completed"
else
	echo "❌ Overwrite test failed - script did not complete"
	exit 1
fi

echo "🎉 Overwrite test completed successfully!"
