#!/bin/bash

# Real package testing with safe copies
# Tests the script with actual dotfiles packages in isolated environment

TEST_BASE="/tmp/stowaway-real-test"
SCRIPT_DIR="$(dirname "$0")"

# Check if real test environment exists
if [[ ! -d "$TEST_BASE" ]]; then
	echo "❌ Real package test environment not found. Run setup-real-packages.sh first."
	exit 1
fi

echo "🧪 Running real package tests..."

# Test 1: Fresh install (no conflicts)
echo ""
echo "📋 Test 1: Fresh install of real packages..."

# Clean target directory
rm -rf "$TEST_BASE/target"/*
mkdir -p "$TEST_BASE/target"

# Run install test
OUTPUT1=$(timeout 15 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_BASE/source" "$TEST_BASE/target" <<<$'i\ni\ni' 2>&1)

if echo "$OUTPUT1" | grep -q "dotfiles installed"; then
	echo "✅ Fresh install test passed"
else
	echo "❌ Fresh install test failed"
	echo "$OUTPUT1"
	exit 1
fi

# Test 2: Basic functionality with real packages
echo ""
echo "📋 Test 2: Basic functionality with real packages..."

# Clean target and add some conflicts that match real package structure
rm -rf "$TEST_BASE/target"/*
mkdir -p "$TEST_BASE/target/.config/zsh"
echo "existing zsh config" >"$TEST_BASE/target/.config/zsh/.zshrc"

OUTPUT2=$(timeout 15 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_BASE/source" "$TEST_BASE/target" <<<$'s\ni\ni' 2>&1)

if echo "$OUTPUT2" | grep -q "dotfiles installed"; then
	echo "✅ Basic functionality test passed"
else
	echo "❌ Basic functionality test failed"
	echo "$OUTPUT2"
	exit 1
fi

# Test 3: Install all functionality
echo ""
echo "📋 Test 3: Install all functionality with real packages..."

# Clean target
rm -rf "$TEST_BASE/target"/*
mkdir -p "$TEST_BASE/target"

OUTPUT3=$(timeout 15 bash "$SCRIPT_DIR/stowaway-check-test.sh" "$TEST_BASE/source" "$TEST_BASE/target" <<<"I" 2>&1)

if echo "$OUTPUT3" | grep -q "dotfiles installed"; then
	echo "✅ Install all test passed"
else
	echo "❌ Install all test failed"
	echo "$OUTPUT3"
	exit 1
fi

echo ""
echo "🎉 All real package tests completed successfully!"
echo ""
echo "📊 Real package testing verified:"
echo "   ✅ Fresh installation works with real packages"
echo "   ✅ Basic functionality works with real packages"
echo "   ✅ Install all functionality works with real packages"
echo "   ✅ Script handles real dotfiles package structure correctly"
