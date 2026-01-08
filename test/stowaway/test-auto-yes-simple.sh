#!/bin/bash

# Test auto-yes mode with single package (no conflicts)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing auto-yes mode (single package)..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with auto-yes mode (6th parameter = true)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "" "true")

echo "🔍 Checking results..."

# Verify no interactive prompts appeared (key indicator of auto-yes working)
verify_no_prompts "$OUTPUT" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was called
verify_stow_called "$TEST_DIR" "pkg1" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Auto-yes simple test completed successfully!"
