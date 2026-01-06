#!/bin/bash

# Safe real package testing setup
# Copies actual dotfiles packages to isolated test environment

REAL_REPO="${HOME}/.dotfiles"
TEST_BASE="/tmp/stowaway-real-test"
SCRIPT_DIR="$(dirname "$0")"

echo "🔧 Setting up safe real package testing environment..."

# Clean up any previous real test environment
rm -rf "$TEST_BASE"

# Create test structure
mkdir -p "$TEST_BASE"/{source,target,expected,logs}

# Select a subset of real packages for testing
PACKAGES_TO_TEST=("zsh" "tmux" "btop")

echo "📦 Copying real packages to test environment (using safe copies)..."

for package in "${PACKAGES_TO_TEST[@]}"; do
	if [[ -d "$REAL_REPO/$package" ]]; then
		echo "  Copying $package..."
		cp -r "$REAL_REPO/$package" "$TEST_BASE/source/"
	else
		echo "  ⚠️  Package $package not found in $REAL_REPO"
	fi
done

# Create some conflicting files in target to test conflict resolution
echo "🎯 Setting up test conflicts..."
mkdir -p "$TEST_BASE/target/.config"
echo "existing zshrc content" >"$TEST_BASE/target/.zshrc"
echo "existing tmux config" >"$TEST_BASE/target/.tmux.conf"
mkdir -p "$TEST_BASE/target/.config/btop"
echo "existing btop config" >"$TEST_BASE/target/.config/btop/btop.conf"

echo "✅ Real package test environment ready!"
echo "   Source: $TEST_BASE/source/"
echo "   Target: $TEST_BASE/target/"
echo "   Logs: $TEST_BASE/logs/"
echo ""
echo "🧪 Run real package tests with:"
echo "   cd test/stowaway && ./test-real-packages.sh"
