#!/bin/bash

# Test script for backup only option (o)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-backup-only"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing backup only functionality..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Set up test environment: create package directory in target to backup
mkdir -p "$TEST_DIR/target/package1/.config"
echo "existing package1 content" >"$TEST_DIR/target/package1/.config/existing.conf"

# Clean up any existing backups
rm -rf "$TEST_DIR/target/package1.backup"

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

# Check if backup directory was created
if [[ -d "$TEST_DIR/target/package1.backup" ]]; then
	echo "✅ Backup-only test passed - backup directory created"
else
	echo "❌ Backup-only test failed - backup directory not found"
	ls -la "$TEST_DIR/target/"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Check that no stow commands were executed (backup only doesn't install)
if echo "$OUTPUT" | grep -q "Installing package1"; then
	echo "❌ Backup-only test failed - package was installed when it shouldn't be"
	cleanup_test_env "$TEST_DIR"
	exit 1
else
	echo "✅ Backup-only test passed - no installation occurred"
fi

# Check that script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was NOT called
verify_stow_not_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Backup only test completed successfully!"
