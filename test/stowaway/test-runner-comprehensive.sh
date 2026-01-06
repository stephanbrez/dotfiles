#!/bin/bash

# Comprehensive test runner for stowaway-check

SCRIPT_DIR="$(dirname "$0")"
TEST_DIR="/tmp/stowaway-test"

echo "🧪 Running comprehensive stowaway-check tests..."
echo "Test directory: $TEST_DIR"

# Ensure test environment is set up
mkdir -p "$TEST_DIR/logs"

# Clean up any previous test artifacts
rm -f "$TEST_DIR/logs/*"
rm -rf "$TEST_DIR/target/package1.backup" 2>/dev/null || true

# Run individual tests
echo ""
echo "📋 Running skip test..."
if bash "$SCRIPT_DIR/test-skip-simple.sh"; then
	echo "✅ Skip test: PASSED"
else
	echo "❌ Skip test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running overwrite test..."
if bash "$SCRIPT_DIR/test-overwrite-simple.sh"; then
	echo "✅ Overwrite test: PASSED"
else
	echo "❌ Overwrite test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running replace test..."
if bash "$SCRIPT_DIR/test-replace-simple.sh"; then
	echo "✅ Replace test: PASSED"
else
	echo "❌ Replace test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running backup then install test..."
if bash "$SCRIPT_DIR/test-backup-install-simple.sh"; then
	echo "✅ Backup-install test: PASSED"
else
	echo "❌ Backup-install test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running backup only test..."
if bash "$SCRIPT_DIR/test-backup-only-simple.sh"; then
	echo "✅ Backup-only test: PASSED"
else
	echo "❌ Backup-only test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running install test..."
if bash "$SCRIPT_DIR/test-install-simple.sh"; then
	echo "✅ Install test: PASSED"
else
	echo "❌ Install test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running add/adopt test..."
if bash "$SCRIPT_DIR/test-add-simple.sh"; then
	echo "✅ Add test: PASSED"
else
	echo "❌ Add test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running skip all test..."
if bash "$SCRIPT_DIR/test-skip-all.sh"; then
	echo "✅ Skip all test: PASSED"
else
	echo "❌ Skip all test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running edge case tests..."
echo "  Testing empty source directory..."
if bash "$SCRIPT_DIR/test-edge-empty-source.sh"; then
	echo "  ✅ Empty source test: PASSED"
else
	echo "  ❌ Empty source test: FAILED"
	exit 1
fi

echo "  Testing read-only target directory..."
if bash "$SCRIPT_DIR/test-edge-permissions.sh"; then
	echo "  ✅ Read-only target test: PASSED"
else
	echo "  ❌ Read-only target test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running dependency tests..."
echo "  Testing missing stow..."
if bash "$SCRIPT_DIR/test-dependency-stow.sh"; then
	echo "  ✅ Missing stow test: PASSED"
else
	echo "  ❌ Missing stow test: FAILED"
	exit 1
fi

echo "  Testing missing target directory..."
if bash "$SCRIPT_DIR/test-dependency-target.sh"; then
	echo "  ✅ Missing target test: PASSED"
else
	echo "  ❌ Missing target test: FAILED"
	exit 1
fi

echo ""
echo "🎉 All tests passed successfully!"
echo ""
echo "📊 Test Summary:"
echo "   ✅ Skip functionality"
echo "   ✅ Replace functionality"
echo "   ✅ Backup then install functionality"
echo "   ✅ Backup only functionality"
echo "   ✅ Install functionality"
echo "   ✅ Add/adopt functionality"
echo "   ✅ Skip all functionality"
echo "   ✅ Dependency checking (stow presence)"
echo "   ✅ Dependency checking (target directory)"
echo "   ✅ Edge case: empty source directory"
echo "   ✅ Edge case: read-only target directory"
echo ""
echo "Next steps: Add remaining 'all' options tests and more edge cases, then real package testing."
