#!/bin/bash

# Test script for add/adopt option (a)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-add"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing add/adopt functionality..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with input file (single character)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "a")

echo "🔍 Checking results..."

# Check that add was processed
check_output_contains "$OUTPUT" "Found existing dots" "Conflict detection worked" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that ONLY ONE prompt appeared
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 1 ]; then
	echo "✅ Add test passed - only one prompt shown"
else
	echo "❌ Add test failed - expected 1 prompt, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was called with --adopt
if [[ -f "$TEST_DIR/logs/stow.log" ]]; then
	if grep -q "stow.*--adopt" "$TEST_DIR/logs/stow.log"; then
		echo "✅ Stow command verified with --adopt flag"
	else
		echo "❌ Stow command missing --adopt flag"
		cat "$TEST_DIR/logs/stow.log"
		cleanup_test_env "$TEST_DIR"
		exit 1
	fi
else
	echo "❌ Stow log not found"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Add/adopt test completed successfully!"
