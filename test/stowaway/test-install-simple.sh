#!/bin/bash

# Test script for install option (i)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing install functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'i' input for packages without conflicts
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"iii" 2>&1)

echo "🔍 Checking results..."

# Check that install prompts appeared
if echo "$OUTPUT" | grep -q "Found package"; then
	echo "✅ Install test passed - install prompts appeared"
else
	echo "❌ Install test failed - no install prompts found"
	echo "Output: $OUTPUT"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Install test passed - script completed"
else
	echo "❌ Install test failed - script did not complete"
	exit 1
fi

echo "🎉 Install test completed successfully!"
