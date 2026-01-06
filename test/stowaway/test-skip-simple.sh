#!/bin/bash

# Simple test script for skip option
# Captures script output to verify behavior

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-skip"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing skip functionality..."

# Setup test environment - only copy source, use fixture's target
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"
# Remove the copied target if exists (we'll use it as-is)
rm -rf "$TEST_DIR/target" 2>/dev/null || true
# Move fixture target to test target
if [ -d "$FIXTURE_DIR/target" ]; then
	cp -r "$FIXTURE_DIR/target" "$TEST_DIR/"
fi

# Run test with input file (two characters for two packages)
SCRIPT_PATH="$SCRIPT_DIR/stowaway-check-test.sh"
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_PATH" \
	"$TEST_DIR/source" "$TEST_DIR/target" "ss")

echo "🔍 Checking results..."

# Check that conflict was detected
check_output_contains "$OUTPUT" "Found existing dots" "Conflict detection worked" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that TWO prompts appeared (one per package)
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 2 ]; then
	echo "✅ Skip test passed - one prompt per package shown"
else
	echo "❌ Skip test failed - expected 2 prompts, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed successfully" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was NOT called (skip option)
verify_stow_not_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Skip test completed successfully!"
