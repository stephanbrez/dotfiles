#!/bin/bash

# Test script for dependency checking - missing target directory

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/basic-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing dependency checking (missing target directory)..."

# Setup test environment (create source only)
mkdir -p "$TEST_DIR/source"
cp -r "$FIXTURE_DIR/source"/* "$TEST_DIR/source/" 2>/dev/null || true

# Create non-existent target directory
NON_EXISTENT_TARGET="$TEST_DIR/non-existent-target"

# Run test with empty input (should fail before reaching prompts)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$NON_EXISTENT_TARGET" "" 5)

echo "🔍 Checking results..."

# Check that the script failed due to missing target directory
check_output_contains "$OUTPUT" "Target directory not found" \
	"Correctly detected missing target directory" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Missing target directory test completed successfully!"
