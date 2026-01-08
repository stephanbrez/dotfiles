#!/bin/bash

# Test .stowaway-ignore: behavior when no ignore file exists (backward compatibility)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/ignore-feature/no-ignore-file"
TEST_DIR="/tmp/stowaway-test-ignore-no-file-$$"

echo "🧪 Testing .stowaway-ignore: backward compatibility (no ignore file)..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Verify .stowaway-ignore file does NOT exist
verify_ignore_file_not_exists "$TEST_DIR" "Ignore file should not exist" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Run test with auto-yes mode
OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
	"$TEST_DIR/source" "$TEST_DIR/target" "" "true")

echo "🔍 Checking results..."

# Verify script completed
check_output_contains "$OUTPUT" "dotfiles installed" "Script completed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify pkg1 was processed
verify_directory_processed "$TEST_DIR" "pkg1" "pkg1 should be processed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify pkg2 was processed
verify_directory_processed "$TEST_DIR" "pkg2" "pkg2 should be processed" || {
	cleanup_test_env "$TEST_DIR"
	exit 1
}

# Verify exactly 2 packages were processed
PACKAGE_COUNT=$(count_processed_packages "$TEST_DIR")
if [ "$PACKAGE_COUNT" -eq 2 ]; then
	echo "✅ Exactly 2 packages processed (backward compatible)"
else
	echo "❌ Expected 2 packages, but found $PACKAGE_COUNT"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 No ignore file test completed successfully!"
