#!/bin/bash
# Batch update test scripts to use fixtures

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Mapping of test files to fixtures
declare -A TEST_FIXTURES=(
	["test-skip-simple.sh"]="conflict-skip"
	["test-replace-simple.sh"]="conflict-replace"
	["test-backup-install-simple.sh"]="conflict-backup-install"
	["test-backup-only-simple.sh"]="conflict-backup-only"
	["test-add-simple.sh"]="conflict-add"
	["test-install-simple.sh"]="basic-install"
	["test-overwrite-simple.sh"]="conflict-replace"
	["test-backup-simple.sh"]="conflict-backup-install"
	["test-skip-all.sh"]="batch-operations"
)

for test_file in "${!TEST_FIXTURES[@]}"; do
	fixture="${TEST_FIXTURES[$test_file]}"
	file_path="$SCRIPT_DIR/$test_file"

	if [[ -f "$file_path" ]]; then
		echo "Updating $test_file to use $fixture fixture..."

		# Create backup
		cp "$file_path" "${file_path}.bak"

		# Replace the TEST_DIR setup section
		sed -i 's|TEST_DIR="/tmp/stowaway-test"|SCRIPT_DIR="$(dirname "$0")"\nFIXTURE_DIR="$SCRIPT_DIR/../fixtures/scenarios/'"$fixture"'"\nTEST_DIR="/tmp/stowaway-test-run-$$"|' "$file_path"

		# Replace the setup section
		sed -i 's|echo "🧪 Testing.*"|\1\n\n# Copy fixture to temporary test directory\nmkdir -p "$TEST_DIR"\ncp -r "$FIXTURE_DIR"/* "$TEST_DIR"/\n\n# Run the test with simulated input and capture output|' "$file_path"

		# Add cleanup at the end
		echo -e "\n# Clean up\nrm -rf \"\$TEST_DIR\"" >>"$file_path"
	fi
done

echo "✅ Test files updated to use fixtures"
