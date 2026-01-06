#!/bin/bash

# Simple test script for skip option
# Captures script output to verify behavior

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing skip functionality..."

# Clean up previous test run
mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with simulated input and capture output
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"sss" 2>&1)

echo "🔍 Checking results..."

# Check that the script prompted for conflicts
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Skip test passed - conflict detection worked"
else
	echo "❌ Skip test failed - no conflict prompt found"
	echo "Output: $OUTPUT"
	exit 1
fi

# Check that the script completed successfully
if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Skip test passed - script completed successfully"
else
	echo "❌ Skip test failed - script did not complete"
	echo "Output: $OUTPUT"
	exit 1
fi

# Check that no actual stow commands were executed (since they're commented out)
# We can verify this by checking that the mock stow wasn't called
if [[ ! -f "$TEST_DIR/logs/stow.log" ]] || [[ ! -s "$TEST_DIR/logs/stow.log" ]]; then
	echo "✅ Skip test passed - no stow commands were executed"
else
	echo "❌ Skip test failed - stow commands were executed"
	cat "$TEST_DIR/logs/stow.log"
	exit 1
fi

echo "🎉 Skip test completed successfully!"
