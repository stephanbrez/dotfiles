#!/bin/bash

# Test script for install option (i)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/basic-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing install functionality..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with input file (single character for single package)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "i")

echo "🔍 Checking results..."

# Check that install prompts appeared
check_output_contains "$OUTPUT" "Found" "Install prompts appeared" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that ONLY ONE prompt appeared
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 1 ]; then
	echo "✅ Install test passed - only one prompt shown"
else
	echo "❌ Install test failed - expected 1 prompt, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was called
verify_stow_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Install test completed successfully!"
