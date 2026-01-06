#!/bin/bash

# Test script for backup only option (o) - duplicate test, checking if we still need it

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-backup-only"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing backup only functionality (overwrite duplicate)..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with input file (single character)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "o")

echo "🔍 Checking results..."

# Check that backup only was processed
check_output_contains "$OUTPUT" "Found existing dots" "Conflict detection worked" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that ONLY ONE prompt appeared
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 1 ]; then
	echo "✅ Backup-only test passed - only one prompt shown"
else
	echo "❌ Backup-only test failed - expected 1 prompt, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was NOT called (backup only)
verify_stow_not_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Backup only test (overwrite duplicate) completed successfully!"
