#!/bin/bash

# Test script for replace option (r)

SCRIPT_DIR="$(dirname "$0")"
FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-replace"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing replace functionality..."

# Copy fixture to temporary test directory
mkdir -p "$TEST_DIR"
cp -r "$FIXTURE_DIR"/* "$TEST_DIR/"

# Run the test with simulated input and capture output
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"rss" 2>&1)

# Clean up
rm -rf "$TEST_DIR"

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
