#!/bin/bash

# Test script for edge case: empty source directory

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/edge-empty-source"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing edge case: empty source directory..."

# Setup test environment (creates empty source)
mkdir -p "$TEST_DIR/empty-source"
mkdir -p "$TEST_DIR/target"
mkdir -p "$TEST_DIR/logs"

# Run the test
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/empty-source" "$TEST_DIR/target" "")

echo "🔍 Checking results..."

# Check that the script handles empty directory gracefully
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Check that no stow commands were executed
verify_stow_not_called "$TEST_DIR" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Empty source directory test completed successfully!"
