#!/bin/bash

# Test script for dependency checking - stow presence

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing dependency checking (stow presence)..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Test 1: Verify stow is detected when present
OUTPUT_PRESENT=$(timeout 5 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"sss" 2>&1)

echo "🔍 Checking results..."

# Check that the script proceeded (didn't fail due to missing stow)
if echo "$OUTPUT_PRESENT" | grep -q "Found existing dots\|Found package"; then
	echo "✅ Dependency test passed - stow was detected and script proceeded"
else
	echo "❌ Dependency test failed - stow detection failed"
	echo "Output: $OUTPUT_PRESENT"
	exit 1
fi

# Note: Testing missing stow would require removing stow from the system,
# which is not done automatically to avoid breaking the system.
# This test verifies the positive case (stow present).

echo "🎉 Stow presence test completed successfully!"
echo "   Note: Missing stow case should be tested manually by temporarily removing stow."
