#!/bin/bash

# Final comprehensive test suite
# Includes all functionality, edge cases, and real package testing

SCRIPT_DIR="$(dirname "$0")"

echo "🎯 Running FINAL comprehensive stowaway-check test suite..."
echo "This includes all functionality, edge cases, and real package testing."
echo ""

# Run the main comprehensive tests
echo "📋 Phase 1: Core functionality tests..."
if bash "$SCRIPT_DIR/test-runner-comprehensive.sh" >/dev/null 2>&1; then
	echo "✅ Core functionality tests: PASSED"
else
	echo "❌ Core functionality tests: FAILED"
	exit 1
fi

# Run real package tests
echo ""
echo "📋 Phase 2: Real package testing..."
if bash "$SCRIPT_DIR/test-real-packages.sh" >/dev/null 2>&1; then
	echo "✅ Real package tests: PASSED"
else
	echo "❌ Real package tests: FAILED"
	exit 1
fi

echo ""
echo "🎉 ALL TESTS PASSED SUCCESSFULLY!"
echo ""
echo "🏆 Final Test Coverage:"
echo "   ✅ Complete user option set (s/S, r/R, b/B, a/A, o/O, i/I)"
echo "   ✅ All conflict resolution strategies"
echo "   ✅ Backup functionality (both variants)"
echo "   ✅ Dependency checking"
echo "   ✅ Edge cases (empty dirs, permissions)"
echo "   ✅ Real dotfiles packages (safe copies only)"
echo "   ✅ Batch processing ('all' options)"
echo ""
echo "🎯 The stowaway-check script is fully tested and ready for production use!"
