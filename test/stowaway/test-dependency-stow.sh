#!/bin/bash

# Test script for dependency checking - stow presence

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/basic-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing dependency checking (stow presence)..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Test: Verify stow is detected when present
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "i")

echo "🔍 Checking results..."

# Check that the script proceeded (didn't fail due to missing stow)
if echo "$OUTPUT" | grep -q "Found"; then
	echo "✅ Dependency test passed - stow was detected and script proceeded"
else
	echo "❌ Dependency test failed - stow detection failed"
	echo "Output: $OUTPUT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Note: Testing missing stow would require removing stow from the system,
# which is not done automatically to avoid breaking the system.
# This test verifies the positive case (stow present).

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Stow presence test completed successfully!"
echo "   Note: Missing stow case should be tested manually by temporarily removing stow."
