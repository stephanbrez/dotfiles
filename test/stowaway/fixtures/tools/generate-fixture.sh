#!/bin/bash
# Generate fixture from templates
# Usage: ./generate-fixture.sh <scenario-name>

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURES_DIR="$(dirname "$TOOLS_DIR")"
TEMPLATES_DIR="$FIXTURES_DIR/templates"

scenario="$1"
if [[ -z "$scenario" ]]; then
	echo "Usage: $0 <scenario-name>"
	exit 1
fi

echo "🔧 Generating fixture: $scenario"

# Create fixture directory
fixture_dir="$FIXTURES_DIR/scenarios/$scenario"
# Use temp directory if the target has permission issues
if [[ "$scenario" == "edge-readonly-target" ]]; then
	fixture_dir="/tmp/fixture-$scenario"
fi
mkdir -p "$fixture_dir"/{source,target,expected}

# Generate based on scenario type
case "$scenario" in
basic-install)
	# Use standard package, empty target
	cp -r "$TEMPLATES_DIR/standard-package"/. "$fixture_dir/source/"
	# Target remains empty
	echo "Basic install scenario generated" >"$fixture_dir/expected/result.txt"
	;;

conflict-*)
	# Create source packages that will conflict with existing target directories
	mkdir -p "$fixture_dir/source/.config"
	echo '[app]\nsetting1 = value1' >"$fixture_dir/source/.config/app.ini"
	mkdir -p "$fixture_dir/source/.local"
	echo 'export PATH="$HOME/bin:$PATH"' >"$fixture_dir/source/.local/profile"

	# Create target with conflicting directories
	mkdir -p "$fixture_dir/target/.config"
	echo '[app]\nexisting_setting = existing_value' >"$fixture_dir/target/.config/app.ini"
	mkdir -p "$fixture_dir/target/.local"
	echo 'export EXISTING_VAR="existing value"' >"$fixture_dir/target/.local/profile"

	case "$scenario" in
	conflict-skip)
		echo "Skip conflicts expected" >"$fixture_dir/expected/result.txt"
		;;
	conflict-replace)
		echo "Replace conflicts expected" >"$fixture_dir/expected/result.txt"
		;;
	conflict-backup-install)
		# Create a package that will conflict with an existing directory
		mkdir -p "$fixture_dir/source/package1/.config"
		echo '[app]\nsetting1 = value1' >"$fixture_dir/source/package1/.config/app.ini"

		# Target has the conflicting package directory
		mkdir -p "$fixture_dir/target/package1/.config"
		echo '[app]\nexisting_setting = existing_value' >"$fixture_dir/target/package1/.config/app.ini"

		echo "Backup then install expected" >"$fixture_dir/expected/result.txt"
		;;
	conflict-backup-only)
		echo "Backup only expected" >"$fixture_dir/expected/result.txt"
		;;
	conflict-add)
		echo "Add/merge expected" >"$fixture_dir/expected/result.txt"
		;;
	esac
	;;

batch-operations)
	# Multiple packages for batch testing
	cp -r "$TEMPLATES_DIR/standard-package" "$fixture_dir/source/package1"
	cp -r "$TEMPLATES_DIR/standard-package" "$fixture_dir/source/package2"
	cp -r "$TEMPLATES_DIR/conflict-environment/target"/. "$fixture_dir/target/"
	echo "Batch operations expected" >"$fixture_dir/expected/result.txt"
	;;

edge-*)
	case "$scenario" in
	edge-empty-source)
		# Empty source directory
		mkdir -p "$fixture_dir/source"
		echo "Empty source handling expected" >"$fixture_dir/expected/result.txt"
		;;
	edge-readonly-target)
		# Readonly target (permissions set during test, not in fixture)
		cp -r "$TEMPLATES_DIR/target-layout/populated"/. "$fixture_dir/target/"
		echo "Readonly target handling expected" >"$fixture_dir/expected/result.txt"
		echo "NOTE: chmod -R 444 target/ # Run during test" >>"$fixture_dir/expected/result.txt"
		;;
	edge-nested-conflicts)
		# Complex nested conflicts
		cp -r "$TEMPLATES_DIR/conflict-environment/source"/. "$fixture_dir/source/"
		cp -r "$TEMPLATES_DIR/conflict-environment/target"/. "$fixture_dir/target/"
		mkdir -p "$fixture_dir/target/.config/nested"
		echo "nested config" >"$fixture_dir/target/.config/nested/config.conf"
		echo "Nested conflicts expected" >"$fixture_dir/expected/result.txt"
		;;
	esac
	;;

*)
	echo "Unknown scenario: $scenario"
	exit 1
	;;
esac

echo "✅ Fixture generated: $scenario"
echo "   Source: $fixture_dir/source/"
echo "   Target: $fixture_dir/target/"
echo "   Expected: $fixture_dir/expected/"
