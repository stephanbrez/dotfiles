#!/bin/bash

# Test that stow runs with correct user (ASME variable)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/basic-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing ASME variable behavior..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with install input (no conflicts)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "i")

echo "🔍 Checking results..."

# Verify script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify mock-stow was called
if [[ -f "$TEST_DIR/logs/stow.log" ]]; then
	echo "✅ Mock stow was called"

	# Verify stow command format in log
	if grep -q "mock-stow called" "$TEST_DIR/logs/stow.log"; then
		echo "✅ Mock stow log entry found"
	else
		echo "❌ Mock stow log not found"
		cat "$TEST_DIR/logs/stow.log"
		cleanup_test_env "$TEST_DIR"
		exit 1
	fi

	# Verify package was stowed
	verify_stow_called "$TEST_DIR" "package" || {
		cleanup_test_env "$TEST_DIR"
		exit 1
	}
else
	echo "❌ Mock stow not called"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 ASME variable test completed successfully!"
