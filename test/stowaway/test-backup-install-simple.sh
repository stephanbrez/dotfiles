#!/bin/bash

# Test script for backup then install option (b)

SCRIPT_DIR="$(dirname "$0")"
FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-backup-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing backup then install functionality..."

# Copy fixture to temporary test directory
mkdir -p "$TEST_DIR"
cp -r "$FIXTURE_DIR"/* "$TEST_DIR/"

# Run the test with simulated input and capture output
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"bss" 2>&1)

echo "🔍 Checking results..."

# Check that backup then install was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Backup-install test passed - conflict detection worked"
else
	echo "❌ Backup-install test failed - no conflict prompt found"
	echo "Output: $OUTPUT"
	exit 1
fi

# Check if backup directory was created
if [[ -d "$TEST_DIR/target/package1.backup" ]]; then
	echo "✅ Backup-install test passed - backup directory created"
else
	echo "❌ Backup-install test failed - backup directory not found"
	echo "Target contents:"
	ls -la "$TEST_DIR/target/" 2>/dev/null || echo "Cannot list target"
	exit 1
fi

# Clean up
rm -rf "$TEST_DIR"

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Backup-install test passed - script completed"
else
	echo "❌ Backup-install test failed - script did not complete"
	exit 1
fi

echo "🎉 Backup then install test completed successfully!"
