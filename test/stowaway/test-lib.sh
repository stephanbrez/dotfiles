#!/bin/bash
# Test helper library for stowaway-check tests

# Run stowaway-check with input from file
run_test_with_input() {
	local test_dir="$1"
	local script="$2"
	local source="$3"
	local target="$4"
	local input="$5"
	local auto_yes="${6:-false}"
	local timeout_sec="${7:-10}"

	local input_file="$test_dir/input.txt"
	echo "$input" >"$input_file"

	# Export log directory for mock-stow to use
	export STOWAWAY_TEST_LOG_DIR="$test_dir/logs"

	# Run test directly without cd (use full path for script)
	local cmd="timeout \"$timeout_sec\" bash \"$script\" \"$source\" \"$target\" <\"$input_file\""
	if [ "$auto_yes" = "true" ]; then
		cmd="timeout \"$timeout_sec\" bash \"$script\" -y \"$source\" \"$target\""
	fi
	eval "$cmd" 2>&1
}

# Setup test environment from fixture
setup_test_env() {
	local fixture_dir="$1"
	local test_dir="$2"

	mkdir -p "$test_dir/logs"
	if [ -d "$fixture_dir" ]; then
		# Copy fixture contents to test directory
		rm -rf "$test_dir/source" "$test_dir/expected" "$test_dir/input.txt" 2>/dev/null || true
		cp -r "$fixture_dir"/* "$test_dir/"
	fi
}

# Cleanup test environment
cleanup_test_env() {
	local test_dir="$1"
	rm -rf "$test_dir"
}

# Verify stow command was logged
verify_stow_called() {
	local test_dir="$1"
	local expected_package="${2:-.*}"
	local expected_cmd="${3:-stow}"

	if [[ ! -f "$test_dir/logs/stow.log" ]]; then
		echo "❌ Stow log not found"
		return 1
	fi

	# Support both old and new stow command formats (with/without -d flag)
	if grep -qE "stow.*-d.*dirname.*$expected_cmd.*$expected_package.*-t.*$test_dir/target|$expected_cmd.*$expected_package.*-t.*$test_dir/target" "$test_dir/logs/stow.log"; then
		echo "✅ Stow command verified: $expected_cmd $expected_package"
		return 0
	else
		echo "❌ Expected stow command not found"
		echo "Looking for: stow.*-d.*dirname.*$expected_cmd.*$expected_package.*-t.*$test_dir/target"
		echo "Log contents:"
		cat "$test_dir/logs/stow.log"
		return 1
	fi
}

# Verify stow was NOT called (ignoring --version checks)
verify_stow_not_called() {
	local test_dir="$1"

	if [[ ! -f "$test_dir/logs/stow.log" ]]; then
		echo "✅ Stow not called (as expected)"
		return 0
	fi

	# Check if there are any actual stow operations (not just --version)
	if grep -v -- '--version' "$test_dir/logs/stow.log" | grep -q 'mock-stow called with: -'; then
		echo "❌ Stow was called when it shouldn't have been"
		cat "$test_dir/logs/stow.log"
		return 1
	else
		echo "✅ Stow not called (as expected)"
		return 0
	fi
}

# Count occurrences of prompt pattern
count_prompts() {
	local output="$1"
	local pattern="$2"

	echo "$output" | grep -c "$pattern" || echo "0"
}

# Check for pattern existence
check_output_contains() {
	local output="$1"
	local pattern="$2"
	local message="$3"

	if echo "$output" | grep -q "$pattern"; then
		echo "✅ $message"
		return 0
	else
		echo "❌ $message - pattern not found: $pattern"
		echo "Output: $output"
		return 1
	fi
}

# Check if target directory exists (graceful handling of missing fixtures)
check_target_exists() {
	local test_dir="$1"

	if [ -d "$test_dir/target" ]; then
		echo "✅ Target directory exists"
		return 0
	else
		echo "❌ Target directory missing - will be created by stow"
		return 0
	fi
}

# Verify auto-yes mode was enabled
verify_auto_yes_enabled() {
	local output="$1"
	local message="${2:-Auto-yes mode enabled}"

	if echo "$output" | grep -q "Auto-yes mode enabled"; then
		echo "✅ $message"
		return 0
	else
		echo "❌ $message - 'Auto-yes mode enabled' not found"
		echo "Output: $output"
		return 1
	fi
}

# Verify no prompts appeared (for auto-yes mode)
verify_no_prompts() {
	local output="$1"
	local message="${2:-No interactive prompts appeared}"

	# Check for prompt patterns (what do you want to do, Found existing dots)
	if echo "$output" | grep -qE "(what do you want to do|Found existing dots)"; then
		echo "❌ $message - unexpected prompt found"
		echo "Output: $output"
		return 1
	else
		echo "✅ $message"
		return 0
	fi
}
