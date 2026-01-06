#!/bin/bash

# Test script for replace option (r)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing replace functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'r' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"rss" 2>&1)

echo "🔍 Checking results..."

# Check that replace was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Replace test passed - conflict detection worked"
else
	echo "❌ Replace test failed - no conflict prompt found"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Replace test passed - script completed"
else
	echo "❌ Replace test failed - script did not complete"
	exit 1
fi

echo "🎉 Replace test completed successfully!"
