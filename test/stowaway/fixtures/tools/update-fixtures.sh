#!/bin/bash
# Automated fixture update system

SCRIPT_DIR="$(dirname "$0")"
FIXTURES_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$(dirname "$FIXTURES_DIR")"

echo "🔄 Automated Fixture Update System"
echo "==================================="

# Create backup
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="$FIXTURES_DIR/backup/$timestamp"
mkdir -p "$backup_dir"

echo "💾 Creating backup in $backup_dir..."
cp -r "$FIXTURES_DIR/scenarios"/* "$backup_dir/" 2>/dev/null || true

# Run test suite
echo "📋 Running test suite..."
cd "$TEST_DIR"
if ./test-runner-comprehensive.sh >test_output.log 2>&1; then
	echo "✅ All tests passed - no fixture updates needed"
	# Auto-clean old backups (keep last 3)
	cd "$FIXTURES_DIR/backup"
	ls -t | tail -n +4 | xargs rm -rf 2>/dev/null || true
	exit 0
fi

# Identify failed tests
echo "🔍 Analyzing test failures..."
failed_scenarios=$(grep "FAILED" test_output.log | sed 's/.*FAILED.*://' | sort | uniq)

if [[ -z "$failed_scenarios" ]]; then
	echo "⚠️  Tests failed but no specific scenarios identified"
	echo "Check test_output.log for details"
	exit 1
fi

# Regenerate failed fixtures
echo "🔧 Regenerating fixtures for failed scenarios..."
cd "$FIXTURES_DIR/tools"
for scenario in $failed_scenarios; do
	# Map test names to fixture names
	case "$scenario" in
	*"skip"* | *"Skip"*) fixture_name="conflict-skip" ;;
	*"replace"* | *"Replace"*) fixture_name="conflict-replace" ;;
	*"backup-install"* | *"backup then install"*) fixture_name="conflict-backup-install" ;;
	*"backup-only"* | *"backup only"*) fixture_name="conflict-backup-only" ;;
	*"add"* | *"Add"*) fixture_name="conflict-add" ;;
	*"batch"* | *"all"*) fixture_name="batch-operations" ;;
	*"empty"*) fixture_name="edge-empty-source" ;;
	*"readonly"* | *"permission"*) fixture_name="edge-readonly-target" ;;
	*"nested"* | *"complex"*) fixture_name="edge-nested-conflicts" ;;
	*"basic"* | *"install"*) fixture_name="basic-install" ;;
	*)
		echo "⚠️  Could not map test '$scenario' to fixture"
		continue
		;;
	esac

	echo "  Regenerating: $fixture_name"
	./generate-fixture.sh "$fixture_name"
done

# Validate updated fixtures
echo "✅ Validating updated fixtures..."
if ./validate-fixtures.sh; then
	echo "🎉 Fixture update completed successfully!"
	echo "💡 Ready to commit code changes and fixture updates together"

	# Auto-clean old backups
	cd "$FIXTURES_DIR/backup"
	ls -t | tail -n +4 | xargs rm -rf 2>/dev/null || true
else
	echo "❌ Validation failed - restoring backup..."
	cp -r "$backup_dir"/* "$FIXTURES_DIR/scenarios/" 2>/dev/null || true
	exit 1
fi
