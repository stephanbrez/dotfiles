#!/bin/bash
# Verify script breaks after first conflict, doesn't check all files

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/edge-nested-conflicts"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing break after first conflict..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with skip input
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "s")

echo "🔍 Checking results..."

# Count how many conflict checks occurred (should be 1, not multiple)
# Look for "checking for" debug messages
CHECK_COUNT=$(echo "$OUTPUT" | grep -c "checking for" || echo "0")
if [ "$CHECK_COUNT" -le 1 ]; then
	echo "✅ Break after first conflict test passed - only checked 1 conflict"
else
	echo "❌ Break after first conflict test failed - checked $CHECK_COUNT conflicts"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Verify script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Break after first conflict test completed successfully!"
