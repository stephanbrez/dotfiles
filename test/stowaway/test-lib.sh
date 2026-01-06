#!/bin/bash
# Test helper library for stowaway-check tests

# Run stowaway-check with input from file
run_test_with_input() {
	local test_dir="$1"
	local script="$2"
	local source="$3"
	local target="$4"
	local input="$5"
	local timeout_sec="${6:-10}"

	local input_file="$test_dir/input.txt"
	echo "$input" >"$input_file"

	# Run test directly without cd (use full path for script)
	timeout "$timeout_sec" bash "$script" "$source" "$target_dir" <"$input_file" 2>&1
}

# Setup test environment from fixture
setup_test_env() {
	local fixture_dir="$1"
	local test_dir="$2"

	mkdir -p "$test_dir/logs"
	if [ -d "$fixture_dir" ]; then
		# Copy fixture contents to test directory
		rm -rf "$test_dir"/* 2>/dev/null || true
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

	if grep -q "stow $expected_cmd $expected_package -t $test_dir/target" "$test_dir/logs/stow.log"; then
		echo "✅ Stow command verified: $expected_cmd $expected_package"
		return 0
	else
		echo "❌ Expected stow command not found"
		echo "Looking for: stow $expected_cmd $expected_package -t $test_dir/target"
		echo "Log contents:"
		cat "$test_dir/logs/stow.log"
		return 1
	fi
}

# Verify stow was NOT called
verify_stow_not_called() {
	local test_dir="$1"

	if [[ ! -f "$test_dir/logs/stow.log" ]] || [[ ! -s "$test_dir/logs/stow.log" ]]; then
		echo "✅ Stow not called (as expected)"
		return 0
	else
		echo "❌ Stow was called when it shouldn't have been"
		cat "$test_dir/logs/stow.log"
		return 1
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
