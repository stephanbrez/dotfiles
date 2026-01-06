# Stowaway-Check Test Suite

## Running Tests

Run all tests:
```bash
cd test/stowaway
bash test-runner-comprehensive.sh
```

Run individual test:
```bash
cd test/stowaway
bash test-skip-simple.sh
```

## Test Structure

```
test/stowaway/
├── test-lib.sh                    # Common test helper functions
├── test-*.sh                     # Individual test scripts
├── test-runner-comprehensive.sh     # Run all tests
├── stowaway-check-test.sh        # Test wrapper (uses mocks)
├── mocks/
│   ├── mock-stow.sh             # Mock stow command
│   └── mock-log-message.sh       # Mock log-message function
└── fixtures/
    └── scenarios/
        ├── basic-install/          # No conflicts
        ├── conflict-* /           # Various conflict scenarios
        ├── batch-operations/      # Multiple packages
        └── edge-*/               # Edge cases
```

## Writing Tests

All tests should use the `test-lib.sh` helper library:

1. Source the test library:
   ```bash
   SCRIPT_DIR="$(dirname "$0")"
   source "$SCRIPT_DIR/test-lib.sh"
   ```

2. Setup test environment:
   ```bash
   FIXTURE_DIR="$SCRIPT_DIR/fixtures/scenarios/conflict-skip"
   TEST_DIR="/tmp/stowaway-test-run-$$"
   setup_test_env "$FIXTURE_DIR" "$TEST_DIR"
   ```

3. Run test with input:
   ```bash
   OUTPUT=$(run_test_with_input "$TEST_DIR" "$SCRIPT_DIR/stowaway-check-test.sh" \
       "$TEST_DIR/source" "$TEST_DIR/target" "s")
   ```

4. Verify output using helpers:
   ```bash
   check_output_contains "$OUTPUT" "pattern" "message"
   verify_stow_called "$TEST_DIR" "package"
   verify_stow_not_called "$TEST_DIR"
   PROMPT_COUNT=$(count_prompts "$OUTPUT" "pattern")
   ```

5. Cleanup:
   ```bash
   cleanup_test_env "$TEST_DIR"
   ```

## Test Categories

- **Single-conflict tests**: Tests with one package, one conflict
- **Multi-package tests**: Tests with multiple packages
- **Batch mode tests**: Tests for "all" options (S, R, B, etc.)
- **Edge case tests**: Empty source, read-only target, etc.
- **Feature tests**: Backup restoration, permission checks, ASME, etc.

## Test Helper Functions

### run_test_with_input
Runs stowaway-check with input from a file instead of herestrings.

```bash
run_test_with_input <test_dir> <script> <source> <target> <input> [timeout]
```

### setup_test_env
Copies fixture files to test directory and creates logs directory.

```bash
setup_test_env <fixture_dir> <test_dir>
```

### cleanup_test_env
Removes test directory and all contents.

```bash
cleanup_test_env <test_dir>
```

### verify_stow_called
Verifies that mock-stow was called with correct parameters.

```bash
verify_stow_called <test_dir> [package] [command]
```

### verify_stow_not_called
Verifies that mock-stow was NOT called (for skip/backup-only tests).

```bash
verify_stow_not_called <test_dir>
```

### check_output_contains
Checks if output contains expected pattern.

```bash
check_output_contains <output> <pattern> <message>
```

### count_prompts
Counts occurrences of a pattern in output.

```bash
PROMPT_COUNT=$(count_prompts "$OUTPUT" "pattern")
```

## Troubleshooting

If tests fail:

1. **Check test output** - It's printed when tests fail
2. **Verify test-lib.sh** - Ensure it's sourced correctly
3. **Check mock-stow.sh** - Verify it's executable and in PATH
4. **Verify fixture structure** - Ensure fixture directories exist and contain files
5. **Check input file** - Input files are created in `$TEST_DIR/input.txt`

## Test Updates for New Behavior

The test suite has been updated to work with the new stowaway-check behavior:

- **Input handling**: Changed from herestrings to input files
- **Single-prompt behavior**: Tests verify only one prompt per package (break after first conflict)
- **Stow execution**: Tests verify stow commands via mock-stow logs
- **Batch mode**: Tests verify "all" options work correctly

## Key Changes from Original Tests

1. **Input mechanism**: All tests now use `run_test_with_input()` with input files instead of `<<<"input"`
2. **Prompt counting**: Tests verify exactly ONE prompt appears per package (not multiple)
3. **Stow verification**: Tests check mock-stow logs to verify commands are properly formatted
4. **Helper functions**: All tests use test-lib.sh for consistency
5. **New tests**: Added tests for backup restoration, write permissions, ASME variable, and break-after-first-conflict behavior

## Test Coverage

Current test suite covers:

- ✅ All conflict resolution options (s, r, b, a, o, i)
- ✅ All batch mode options (S, R, B, A, O, I)
- ✅ Backup functionality (both variants)
- ✅ Dependency checking (stow presence, target directory)
- ✅ Edge cases (empty source, read-only target)
- ✅ Batch processing with multiple packages
- ✅ Break after first conflict behavior
- ✅ Write permission checking
- ✅ ASME variable behavior (user ownership)
- ✅ Backup restoration on interrupt
- ✅ Stow command execution and formatting

Total: 20 automated tests
