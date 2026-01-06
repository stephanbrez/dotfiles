#!/bin/bash
# Basic fixture validation

SCRIPT_DIR="$(dirname "$0")"
FIXTURES_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔍 Running basic fixture validation..."

errors=0

# Check scenarios
for fixture in "$FIXTURES_DIR/scenarios"/*; do
	if [[ ! -d "$fixture" ]]; then
		continue
	fi

	scenario_name=$(basename "$fixture")

	# Check required directories
	if [[ ! -d "$fixture/source" ]]; then
		echo "❌ Missing source directory in $scenario_name"
		((errors++))
	fi

	if [[ ! -d "$fixture/target" ]]; then
		echo "❌ Missing target directory in $scenario_name"
		((errors++))
	fi

	if [[ ! -d "$fixture/expected" ]]; then
		echo "❌ Missing expected directory in $scenario_name"
		((errors++))
	fi

	# Check for at least one expected result file
	if [[ ! -f "$fixture/expected/result.txt" ]]; then
		echo "❌ Missing expected result in $scenario_name"
		((errors++))
	fi
done

# Check real packages
for fixture in "$FIXTURES_DIR/real-packages"/*; do
	if [[ ! -d "$fixture" ]]; then
		continue
	fi

	package_name=$(basename "$fixture")

	if [[ ! -d "$fixture/source" ]]; then
		echo "❌ Missing source directory in real package $package_name"
		((errors++))
	fi

	if [[ ! -d "$fixture/target" ]]; then
		echo "❌ Missing target directory in real package $package_name"
		((errors++))
	fi
done

# Report results
if [[ $errors -eq 0 ]]; then
	echo "✅ All fixtures validated successfully"
	exit 0
else
	echo "❌ Found $errors validation errors"
	exit 1
fi
