#!/bin/bash

# Test script for add/adopt option (a)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing add/adopt functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with 'a' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"ass" 2>&1)

echo "🔍 Checking results..."

# Check that add was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Add test passed - conflict detection worked"
else
	echo "❌ Add test failed - no conflict prompt found"
	exit 1
fi

# Check that stow command included --adopt
if echo "$OUTPUT" | grep -q "stow -S.*--adopt"; then
	echo "✅ Add test passed - adopt flag was used in stow command"
else
	echo "❌ Add test failed - adopt flag not found in stow command"
	echo "Output: $OUTPUT"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Add test passed - script completed"
else
	echo "❌ Add test failed - script did not complete"
	exit 1
fi

echo "🎉 Add/adopt test completed successfully!"
