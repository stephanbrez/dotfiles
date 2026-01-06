#!/bin/bash

# Test script for dependency checking - missing target directory

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing dependency checking (missing target directory)..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run the test with non-existent target directory
NON_EXISTENT_TARGET="/tmp/non-existent-target-directory-$$"
echo "Testing with target directory: $NON_EXISTENT_TARGET"
if [[ -e "$NON_EXISTENT_TARGET" ]]; then
	echo "ERROR: Target directory already exists!"
	exit 1
fi
OUTPUT=$(timeout 5 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$NON_EXISTENT_TARGET" <<<"" 2>&1)

echo "🔍 Checking results..."

# Check that the script failed due to missing target directory
if echo "$OUTPUT" | grep -q "Target directory not found"; then
	echo "✅ Dependency test passed - correctly detected missing target directory"
else
	echo "❌ Dependency test failed - did not detect missing target directory"
	echo "Output: $OUTPUT"
	exit 1
fi

echo "🎉 Missing target directory test completed successfully!"
