#!/bin/bash

# Test write permission check

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/basic-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing write permission check..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Create unwritable target directory
mkdir -p "$TEST_DIR/unwritable-target"
chmod 555 "$TEST_DIR/unwritable-target"

# Run test with install input
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/unwritable-target" "i" 5)

echo "🔍 Checking results..."

# Verify error message
check_output_contains "$OUTPUT" "Cannot write to target directory" \
	"Write permission check failed appropriately" || {
	# Cleanup before exit
	chmod 755 "$TEST_DIR/unwritable-target" 2>/dev/null
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify script did NOT complete
if ! echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Script did not complete (as expected)"
else
	echo "❌ Script completed when it should have failed"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Cleanup
chmod 755 "$TEST_DIR/unwritable-target"
cleanup_test_env "$TEST_DIR"

echo "🎉 Write permission test completed successfully!"
