#!/bin/bash

# Test script for backup only option (o)

TEST_DIR="/tmp/stowaway-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🧪 Testing backup only functionality..."

mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Set up test environment: create package directory in target to backup
mkdir -p "$TEST_DIR/target/package1/.config"
echo "existing package1 content" >"$TEST_DIR/target/package1/.config/existing.conf"

# Clean up any existing backups
rm -rf "$TEST_DIR/target/package1.backup"

# Run the test with 'o' input for the first conflict
OUTPUT=$(timeout 10 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_DIR/source" "$TEST_DIR/target" <<<"oss" 2>&1)

echo "🔍 Checking results..."

# Check that backup only was processed
if echo "$OUTPUT" | grep -q "Found existing dots"; then
	echo "✅ Backup-only test passed - conflict detection worked"
else
	echo "❌ Backup-only test failed - no conflict prompt found"
	exit 1
fi

# Check if backup directory was created
if [[ -d "$TEST_DIR/target/package1.backup" ]]; then
	echo "✅ Backup-only test passed - backup directory created"
else
	echo "❌ Backup-only test failed - backup directory not found"
	ls -la "$TEST_DIR/target/"
	exit 1
fi

# Check that no stow commands were executed (since backup only doesn't install)
if echo "$OUTPUT" | grep -q "Installing package1"; then
	echo "❌ Backup-only test failed - package was installed when it shouldn't be"
	exit 1
else
	echo "✅ Backup-only test passed - no installation occurred"
fi

if echo "$OUTPUT" | grep -q "dotfiles installed"; then
	echo "✅ Backup-only test passed - script completed"
else
	echo "❌ Backup-only test failed - script did not complete"
	exit 1
fi

echo "🎉 Backup only test completed successfully!"
