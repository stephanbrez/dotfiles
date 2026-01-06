#!/bin/bash
# Test backup restoration on interrupt (simplified - tests cleanup function directly)

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/test-lib.sh"

FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-backup-install"
TEST_DIR="/tmp/stowaway-test-run-$$"

echo "🧪 Testing backup restoration..."

# Setup test environment
setup_test_env "$FIXTURE_DIR" "$TEST_DIR"

# Manually create a backup to test restoration
mkdir -p "$TEST_DIR/target/package1"
echo "existing content" >"$TEST_DIR/target/package1/test-file.txt"
BACKUP_DST="${TEST_DIR}/target/package1.backup"
mv "$TEST_DIR/target/package1" "$BACKUP_DST"

echo "Created backup: $BACKUP_DST"

# Simulate backup tracking (same as stowaway-check does)
BACKUPS_CREATED=()
BACKUPS_CREATED+=("$BACKUP_DST:$TEST_DIR/target/package1")

# Test cleanup function directly by sourcing stowaway-check
# and calling cleanup()
cd "$SCRIPT_DIR"
source "../bin/.local/bin/stowaway-check" 2>/dev/null || true

# Call cleanup function (should restore backup)
cleanup

# Wait for cleanup to complete
sleep 1

echo "🔍 Checking results..."

# Verify backup was restored to target directory
if [[ -d "$TEST_DIR/target/package1" ]]; then
	echo "✅ Backup restored to target directory"
else
	echo "❌ Backup not restored"
	ls -la "$TEST_DIR/target/"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Verify backup directory no longer exists (was moved back)
if [[ ! -d "$BACKUP_DST" ]]; then
	echo "✅ Backup directory moved back from restoration"
else
	echo "❌ Backup directory still exists after restoration"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Verify content was preserved
if [[ -f "$TEST_DIR/target/package1/test-file.txt" ]]; then
	echo "✅ Backup content preserved during restoration"
else
	echo "❌ Backup content not preserved"
	cleanup_test_env "$TEST_DIR"
	exit 1
fi

# Cleanup
cleanup_test_env "$TEST_DIR"

echo "🎉 Backup restoration test completed successfully!"
