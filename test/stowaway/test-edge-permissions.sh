#!/bin/bash

# Test script for edge case: read-only target directory

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing edge case: read-only target directory..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Create read-only target directory
mkdir -p "$TEST_DIR/readonly-target"
chmod 444 "$TEST_DIR/readonly-target"

# Run the test (should fail gracefully)
OUTPUT=$(timeout 5 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/readonly-target" <<<"" 2>&1)

echo "🔍 Checking results..."

# The script should either fail gracefully or handle the permission issue
# Since stow might fail, we check that the script doesn't crash
if echo "$OUTPUT" | grep -q "dotfiles installed\|FAIL"; then
	echo "✅ Read-only target test passed - script handled permissions appropriately"
else
	echo "❌ Read-only target test failed - unexpected behavior"
	echo "Output: $OUTPUT"
	exit 1
fi

# Cleanup
chmod 755 "$TEST_DIR/readonly-target" 2>/dev/null || true

echo "🎉 Read-only target directory test completed successfully!"
