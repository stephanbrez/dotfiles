#!/bin/bash

# Test script for backup then install option (b)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing backup then install functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Set up test environment: create package directory in target to backup
mkdir -p "$TEST_DIR/target/package1/.config"
echo "existing package1 content" >"$TEST_DIR/target/package1/.config/existing.conf"

# Clean up any existing backups
rm -rf "$TEST_DIR/target/package1.backup"

# Run the test with 'b' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"bss" 2>&1)

echo "🔍 Checking results..."

# Check that backup then install was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Backup-install test passed - conflict detection worked"
else
	echo "❌ Backup-install test failed - no conflict prompt found"
	exit 1
fi

# Check if backup directory was created
if [[ -d "$TEST_DIR/target/package1.backup" ]]; then
	echo "✅ Backup-install test passed - backup directory created"
else
	echo "❌ Backup-install test failed - backup directory not found"
	ls -la "$TEST_DIR/target/"
	exit 1
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Backup-install test passed - script completed"
else
	echo "❌ Backup-install test failed - script did not complete"
	exit 1
fi

echo "🎉 Backup then install test completed successfully!"
