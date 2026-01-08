#!/bin/bash

# Comprehensive test runner for stowaway-check

SCRIPT_DIR="$(dirname "$0")"
TEST_DIR="/tmp/stowaway-test"

echo "🧪 Running comprehensive stowaway-check tests..."
echo "Test directory: $TEST_DIR"

# Ensure test environment is set up
mkdir -p "$TEST_DIR/logs"
rm -f "$TEST_DIR/logs/*"

# Run existing tests (updated)
echo ""
echo "📋 Running skip test..."
if bash "$SCRIPT_DIR/test-skip-simple.sh"; then
	echo "✅ Skip test: PASSED"
else
	echo "❌ Skip test: FAILED"
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
echo "📋 Running auto-yes tests..."
echo "  Testing auto-yes simple..."
if bash "$SCRIPT_DIR/test-auto-yes-simple.sh"; then
	echo "  ✅ Auto-yes simple test: PASSED"
else
	echo "  ❌ Auto-yes simple test: FAILED"
	exit 1
fi

echo "  Testing auto-yes multiple packages..."
if bash "$SCRIPT_DIR/test-auto-yes-multiple.sh"; then
	echo "  ✅ Auto-yes multiple test: PASSED"
else
	echo "  ❌ Auto-yes multiple test: FAILED"
	exit 1
fi

echo "  Testing auto-yes with conflicts..."
if bash "$SCRIPT_DIR/test-auto-yes-with-conflicts.sh"; then
	echo "  ✅ Auto-yes with conflicts test: PASSED"
else
	echo "  ❌ Auto-yes with conflicts test: FAILED"
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
if bash "$SCRIPT_DIR/test-edge-permissions.sh" 2>/dev/null; then
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

# Run new feature tests
echo ""
echo "📋 Running backup restoration test..."
if bash "$SCRIPT_DIR/test-interrupt-restore.sh"; then
	echo "✅ Backup restoration test: PASSED"
else
	echo "❌ Backup restoration test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running write permission test..."
if bash "$SCRIPT_DIR/test-write-permission.sh"; then
	echo "✅ Write permission test: PASSED"
else
	echo "❌ Write permission test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running break after first conflict test..."
if bash "$SCRIPT_DIR/test-break-first-conflict.sh"; then
	echo "✅ Break after first conflict test: PASSED"
else
	echo "❌ Break after first conflict test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running ASME variable test..."
if bash "$SCRIPT_DIR/test-asme-variable.sh"; then
	echo "✅ ASME variable test: PASSED"
else
	echo "❌ ASME variable test: FAILED"
	exit 1
fi

echo ""
echo "📋 Running .stowaway-ignore feature tests..."
echo "  Testing basic directory exclusion..."
if bash "$SCRIPT_DIR/test-ignore-basic.sh"; then
	echo "  ✅ Basic ignore test: PASSED"
else
	echo "  ❌ Basic ignore test: FAILED"
	exit 1
fi

echo "  Testing wildcard pattern exclusion..."
if bash "$SCRIPT_DIR/test-ignore-wildcards.sh"; then
	echo "  ✅ Wildcard ignore test: PASSED"
else
	echo "  ❌ Wildcard ignore test: FAILED"
	exit 1
fi

echo "  Testing behavior without ignore file..."
if bash "$SCRIPT_DIR/test-ignore-no-file.sh"; then
	echo "  ✅ No ignore file test: PASSED"
else
	echo "  ❌ No ignore file test: FAILED"
	exit 1
fi

echo "  Testing empty ignore file..."
if bash "$SCRIPT_DIR/test-ignore-empty-file.sh"; then
	echo "  ✅ Empty ignore file test: PASSED"
else
	echo "  ❌ Empty ignore file test: FAILED"
	exit 1
fi

echo "  Testing comment and whitespace handling..."
if bash "$SCRIPT_DIR/test-ignore-comments.sh"; then
	echo "  ✅ Comment handling test: PASSED"
else
	echo "  ❌ Comment handling test: FAILED"
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
echo "   ✅ Auto-yes mode (single package)"
echo "   ✅ Auto-yes mode (multiple packages)"
echo "   ✅ Auto-yes mode (with conflicts)"
echo "   ✅ Dependency checking (stow presence)"
echo "   ✅ Dependency checking (target directory)"
echo "   ✅ Edge case: empty source directory"
echo "   ✅ Edge case: read-only target directory"
echo "   ✅ Backup restoration on interrupt"
echo "   ✅ Write permission checking"
echo "   ✅ Break after first conflict"
echo "   ✅ ASME variable behavior"
echo "   ✅ .stowaway-ignore: basic exclusion"
echo "   ✅ .stowaway-ignore: wildcard patterns"
echo "   ✅ .stowaway-ignore: backward compatibility"
echo "   ✅ .stowaway-ignore: empty file handling"
echo "   ✅ .stowaway-ignore: comment handling"
echo ""
echo "All tests verify stow command execution via mock-stow!"

# Cleanup base test directory (but preserve logs for review)
rm -rf "$TEST_DIR/source" "$TEST_DIR/target" "$TEST_DIR/readonly-target" "$TEST_DIR/empty-source" 2>/dev/null || true
echo ""
echo "🧹 Cleaned up test artifacts (logs preserved)"
