#!/bin/bash

# Test script for "skip all" functionality (S)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing skip all functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'S' (skip all) for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"S" 2>&1)

echo "🔍 Checking results..."

# Check that skip all worked - should skip all packages without individual prompts
if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Skip all test passed - script completed successfully"
else
	echo "❌ Skip all test failed - script did not complete"
	echo "Output: $OUTPUT"
	exit 1
fi

# Should not see individual package prompts after the first
PACKAGE_PROMPTS=$(echo "$OUTPUT" | grep -c "Found package")
if [[ $PACKAGE_PROMPTS -le 1 ]]; then
	echo "✅ Skip all test passed - batch processing worked"
else
	echo "❌ Skip all test failed - individual prompts appeared"
	exit 1
fi

echo "🎉 Skip all test completed successfully!"
