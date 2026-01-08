#!/bin/bash

# Test script for backup then install option (b)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-backup-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing backup then install functionality..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Verify target directory exists
check_target_exists "$TEST_DIR" || exit 1

# Run test with backup-install (b) for single package
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "b")

echo "🔍 Checking results..."

# Check that backup then install was processed
check_output_contains "$OUTPUT" "Found existing dots" "Conflict detection worked" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that ONLY ONE prompt appeared
PROMPT_COUNT=$(count_prompts "$OUTPUT" "what do you want to do")
if [ "$PROMPT_COUNT" -eq 1 ]; then
	echo "✅ Backup-install test passed - only one prompt shown"
else
	echo "❌ Backup-install test failed - expected 1 prompt, got $PROMPT_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check if backup directory was created (pkg1.backup)
if [[ -d "$TEST_DIR/target/pkg1.backup" ]]; then
	echo "✅ Backup-install test passed - backup directory created"
else
	echo "❌ Backup-install test failed - backup directory not found"
	ls -la "$TEST_DIR/target/" 2>/dev/null || echo "Cannot list target"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was called
if [[ -f "$TEST_DIR/logs/stow.log" ]]; then
	if grep -q "mock-stow called" "$TEST_DIR/logs/stow.log"; then
		echo "✅ Stow command executed"
	else
		echo "❌ Stow command not found in log"
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

echo "🎉 Backup then install test completed successfully!"
