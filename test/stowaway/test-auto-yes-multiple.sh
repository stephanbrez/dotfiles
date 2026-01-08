#!/bin/bash

# Test auto-yes mode with multiple packages

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/auto-yes/multiple-packages"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing auto-yes mode (multiple packages)..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Run test with auto-yes mode (6th parameter = true)
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "" "true")

echo "🔍 Checking results..."

# Verify no interactive prompts appeared
verify_no_prompts "$OUTPUT" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify stow was called for both packages
if [[ -f "$TEST_DIR/logs/stow.log" ]]; then
	pkg1_called=$(grep -c "pkg1" "$TEST_DIR/logs/stow.log" 2>/dev/null || echo "0")
	pkg2_called=$(grep -c "pkg2" "$TEST_DIR/logs/stow.log" 2>/dev/null || echo "0")
	if [ "$pkg1_called" -gt 0 ] && [ "$pkg2_called" -gt 0 ]; then
		echo "✅ Both packages were stowed"
	else
		echo "❌ Not all packages were stowed (pkg1: $pkg1_called, pkg2: $pkg2_called)"
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

echo "🎉 Auto-yes multiple packages test completed successfully!"
