#!/bin/bash

# Test script for "skip all" functionality (S)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/batch-operations"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing skip all functionality..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with 'S' (skip all) - single input for batch mode
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "S")

echo "🔍 Checking results..."

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that only FIRST package prompted (batch mode)
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 1 ]; then
	echo "✅ Skip all test passed - only first package prompted"
else
	echo "❌ Skip all test failed - expected 1 prompt, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Verify stow was NOT called (skip all)
verify_stow_not_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Skip all test completed successfully!"
