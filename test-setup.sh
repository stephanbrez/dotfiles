#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════╗
# ║  Docker Test Script for Setup                                      ║
# ║  Tests the setup script in isolated containers                     ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
LOG_DIR="$SCRIPT_DIR/test-logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create log directory
mkdir -p "$LOG_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
	echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  $1${NC}"
	echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
	echo -e "${RED}✗ $1${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
	echo -e "${CYAN}ℹ $1${NC}"
}

show_help() {
	cat <<EOF
Usage: $0 [OPTIONS] [DISTRO]

Test the setup script in Docker containers.
Note: Auto-yes mode (-y) is always enabled for non-interactive testing.
All output is logged to test-logs/ directory for review.

Options:
  -n, --dry-run     Run setup in dry-run mode (no actual changes)
  -v, --verbose     Run setup in verbose mode (detailed output)
  -f, --full        Run setup in full install mode (override Ubuntu minimal)
  -i, --interactive Run container interactively (for debugging)
  -a, --all         Test all supported distros
  --dispatch        Docker-free dispatch check only (YAML keys → installer
                    functions; covers ALL distros incl. macOS). Auto-runs as
                    a pre-flight before any container test.
  -h, --help        Show this help message

Distros:
  ubuntu            Test on Ubuntu 24.04 LTS
  debian            Test on Debian Bookworm
  fedora            Test on Fedora latest

Note: macOS cannot be container-tested, but its third_party dispatch coverage
is included in the --dispatch check (and the auto pre-flight).

Examples:
  $0 ubuntu                    # Minimal test on Ubuntu (default)
  $0 --full ubuntu             # Full install test on Ubuntu
  $0 --dry-run debian          # Dry-run test on Debian (safe, no changes)
  $0 --dry-run --verbose --all # Verbose dry-run on all distros
  $0 --dispatch                # Dispatch check only (no Docker needed)
  $0 -i ubuntu                 # Interactive Ubuntu container for debugging

Logs:
  Logs are stored in test-logs/ with format: {distro}_{timestamp}.log
  To view the latest log: tail -f test-logs/ubuntu_*.log | tail -1
EOF
	exit 0
}

# Parse arguments
DRY_RUN=""
VERBOSE=""
FULL_MODE=""
INTERACTIVE=""
TEST_ALL=""
DISTRO=""
DISPATCH_ONLY=""

while [[ $# -gt 0 ]]; do
	case $1 in
	-n | --dry-run)
		DRY_RUN="-n"
		shift
		;;
	-v | --verbose)
		VERBOSE="-v"
		shift
		;;
	-f | --full)
		FULL_MODE="-f"
		shift
		;;
	-i | --interactive)
		INTERACTIVE="yes"
		shift
		;;
	-a | --all)
		TEST_ALL="yes"
		shift
		;;
	--dispatch)
		DISPATCH_ONLY="yes"
		shift
		;;
	-h | --help)
		show_help
		;;
	ubuntu | debian | fedora)
		DISTRO="$1"
		shift
		;;
	*)
		echo "Unknown option: $1"
		show_help
		;;
	esac
done

# ─── Dispatch pre-flight: YAML third_party keys resolve to installer functions ───
# Docker-free, PyYAML-free unit test covering ALL distros (incl. macOS, which
# can't be container-tested). Runs two checks:
#   1. Every third_party YAML key → install_<key-with-underscores>() exists
#      (catches enabled-key-without-function; the silent-skip regression class)
#   2. Every installers/*.sh (excl. common.sh, packages-fallback.sh) defines
#      install_<name-with-underscores>() (catches rename-without-function-update)
# Exits 0 on pass, 1 on fail. Safe under `set -e`.
run_dispatch_check() {
	local failures=0

	print_header "Dispatch pre-flight (Docker-free)"

	# ─── Source all installers (guarded) ───
	local f
	for f in "$DOTFILES_DIR"/installers/*.sh; do
		[[ -f "$f" ]] || continue
		case "$(basename "$f")" in
		common.sh | packages-fallback.sh) continue ;;
		esac
		if ! source "$f" &>/dev/null; then
			print_error "Failed to source: $(basename "$f")"
			failures=$((failures + 1))
		fi
	done

	# ─── Check 1: third_party YAML keys → function ───
	# Extract keys via grep (6-space indent, inline bool); no PyYAML needed.
	local keys key func
	keys=$(grep -hE '^      [a-z][a-z0-9_-]*: (true|false)' "$DOTFILES_DIR/packages.yaml" \
		| awk -F: '{print $1}' \
		| tr -d ' ' \
		| sort -u)

	if [[ -z "$keys" ]]; then
		print_error "No third_party keys found in packages.yaml"
		return 1
	fi

	local key_count
	key_count=$(printf '%s\n' "$keys" | grep -c .)
	print_info "Check 1: $key_count unique third_party keys → install_<key>()"
	while IFS= read -r key; do
		[[ -z "$key" ]] && continue
		func="install_${key//-/_}"
		if ! declare -f "$func" &>/dev/null; then
			print_error "YAML key '$key' → missing function '$func'"
			failures=$((failures + 1))
		fi
	done < <(printf '%s\n' "$keys")

	# ─── Check 2: installer filename → function ───
	print_info "Check 2: installers/*.sh → install_<name>() defined"
	local name
	for f in "$DOTFILES_DIR"/installers/*.sh; do
		[[ -f "$f" ]] || continue
		name="$(basename "$f")"
		case "$name" in
		common.sh | packages-fallback.sh) continue ;;
		esac
		name="${name%.sh}"
		func="install_${name//-/_}"
		if ! declare -f "$func" &>/dev/null; then
			print_error "Installer '$(basename "$f")' → missing function '$func'"
			failures=$((failures + 1))
		fi
	done

	if [[ $failures -eq 0 ]]; then
		print_success "Dispatch check passed (all keys + files resolve)"
		return 0
	else
		print_error "Dispatch check failed: $failures mismatch(es)"
		return 1
	fi
}

# ─── Log assertion: surface silent dispatch failures from container runs ───
# setup's auto-discovery loop logs a WARNING (force-printed) and continues on
# missing installer functions, so a regression can pass a coarse exit-0 check.
# This asserts the log is free of those warnings. Safe under `set -e`.
assert_distro_log() {
	local logfile=$1
	local distro=$2
	local assert_failed=0

	# HARD FAIL: dispatch miss (setup: "No installer function ... — skipping")
	if grep -q "No installer function" "$logfile" 2>/dev/null; then
		print_error "$distro: dispatch miss detected in log"
		grep -- "No installer function" "$logfile" | while IFS= read -r line; do
			print_error "  $line"
		done
		assert_failed=1
	fi

	# Informational: count WARNING lines (some are legitimate, e.g. macOS-only
	# aerospace skipped on Linux). Reported, not failed.
	# `grep -c` prints the count AND exits 1 on zero matches; redirect its
	# output to a var and default to 0 only when the file is missing.
	local warn_count=0
	if [[ -f "$logfile" ]]; then
		warn_count=$(grep -c "WARNING" "$logfile" 2>/dev/null || true)
		[[ -z "$warn_count" ]] && warn_count=0
	fi
	if [[ "${warn_count:-0}" -gt 0 ]]; then
		print_warning "$distro: $warn_count WARNING line(s) in log (review for legitimacy)"
	fi

	if [[ $assert_failed -eq 1 ]]; then
		return 1
	fi
	return 0
}

# ─── Test function for a single distro ───
test_distro() {
	local distro=$1
	local image=""
	local base_setup=""
	local setup_flags="-y" # Always use auto-yes for non-interactive testing

	# Add optional flags if requested
	[[ -n "$DRY_RUN" ]] && setup_flags="$setup_flags -n"
	[[ -n "$VERBOSE" ]] && setup_flags="$setup_flags -v"
	[[ -n "$FULL_MODE" ]] && setup_flags="$setup_flags -f"

	case $distro in
	ubuntu)
		image="ubuntu:24.04"
		base_setup="apt-get update && apt-get install -y sudo lsb-release git"
		;;
	debian)
		image="debian:bookworm"
		base_setup="apt-get update && apt-get install -y sudo lsb-release git"
		;;
	fedora)
		image="fedora:latest"
		base_setup="dnf install -y sudo git"
		;;
	*)
		print_error "Unknown distro: $distro"
		return 1
		;;
	esac

	# ─── Create test user and run setup with sudo ───
	# Simulates: user clones repo with 'git clone <url> ~/.dotfiles', then runs 'sudo ./setup'
	# Copy full repo (excluding .git) to simulate a fresh clone
	local setup_cmd="$base_setup && \
        useradd -m -s /bin/bash testuser && \
        echo 'testuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/testuser && \
        mkdir -p /home/testuser/.dotfiles && \
        tar -C /tmp/dotfiles-src --exclude='.git' --exclude='test-logs' -cf - . | tar -xf - -C /home/testuser/.dotfiles && \
        chown -R testuser:testuser /home/testuser/.dotfiles && \
        su - testuser -c \"sudo bash /home/testuser/.dotfiles/setup $setup_flags; echo \\\$? > /tmp/setup_exit; command -v eza >/dev/null 2>&1 && { eza --tree -L 1 /home/testuser; eza --tree -L 2 /home/testuser/.config; } || true; exit \\\$(cat /tmp/setup_exit)\""

	local logfile="$LOG_DIR/${distro}_${TIMESTAMP}.log"

	print_header "Testing on $distro ($image)"
	print_info "Log file: $logfile"

	if [[ -n "$INTERACTIVE" ]]; then
		print_warning "Starting interactive container..."
		print_warning "Logged in as testuser (use 'sudo ~/.dotfiles/setup -n' to test)"
		docker run --rm -it \
			-v "$DOTFILES_DIR:/tmp/dotfiles-src:ro" \
			"$image" \
			bash -c "$base_setup && \
                useradd -m -s /bin/bash testuser && \
                echo 'testuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/testuser && \
                mkdir -p /home/testuser/.dotfiles && \
                tar -C /tmp/dotfiles-src --exclude='.git' --exclude='test-logs' -cf - . | tar -xf - -C /home/testuser/.dotfiles && \
                chown -R testuser:testuser /home/testuser/.dotfiles && \
                su - testuser"
	else
		{
			echo "Starting test at $(date)"
			echo "Distro: $distro"
			echo "Image: $image"
			echo "Command: $setup_cmd"
			echo "════════════════════════════════════════"
			echo ""
		} >"$logfile"

		print_info "Running test... (output redirected to log)"

		if docker run --rm \
			-v "$DOTFILES_DIR:/tmp/dotfiles-src:ro" \
			"$image" \
			bash -c "$setup_cmd" >>"$logfile" 2>&1; then
			{
				echo ""
				echo "════════════════════════════════════════"
				echo "Test completed successfully at $(date)"
			} >>"$logfile"
			if assert_distro_log "$logfile" "$distro"; then
				print_success "$distro test passed"
				print_info "Full log: $logfile"
				return 0
			else
				print_error "$distro test failed: log assertion"
				print_error "Check log for details: $logfile"
				return 1
			fi
		else
			{
				echo ""
				echo "════════════════════════════════════════"
				echo "Test failed at $(date)"
			} >>"$logfile"
			assert_distro_log "$logfile" "$distro" || true
			print_error "$distro test failed"
			print_error "Check log for details: $logfile"
			return 1
		fi
	fi
}

# ─── Main ───

# --dispatch only: Docker-free unit test, then exit (no container tests)
if [[ -n "$DISPATCH_ONLY" ]]; then
	run_dispatch_check
	exit $?
fi

# ─── Auto pre-flight: dispatch check before anything Docker-bound ───
# Fail-fast on YAML-key → installer-function regressions (covers ALL distros
# incl. macOS, which can't be container-tested). Cheap, no Docker needed, so
# it surfaces regressions even on hosts without Docker installed.
if ! run_dispatch_check; then
	print_error "Dispatch pre-flight failed; aborting before container tests"
	exit 1
fi

# Check if Docker is available
if ! command -v docker &>/dev/null; then
	print_error "Docker is not installed or not in PATH"
	exit 1
fi

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
	print_error "Docker daemon is not running"
	exit 1
fi

print_header "Setup Script Docker Test"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Log directory: $LOG_DIR"
echo "Dry-run mode: ${DRY_RUN:-disabled}"
echo "Verbose mode: ${VERBOSE:-disabled}"
echo "Full install: ${FULL_MODE:-disabled}"
echo ""

if [[ -n "$TEST_ALL" ]]; then
	# Test all distros
	FAILED=0
	for dist in ubuntu debian fedora; do
		if ! test_distro "$dist"; then
			FAILED=$((FAILED + 1))
		fi
		echo ""
	done

	print_header "Test Summary"
	if [[ $FAILED -eq 0 ]]; then
		print_success "All tests passed!"
	else
		print_error "$FAILED test(s) failed"
		exit 1
	fi
elif [[ -n "$DISTRO" ]]; then
	# Test specific distro
	test_distro "$DISTRO"
else
	# No distro specified, show help
	print_warning "No distro specified. Use -a for all, or specify: ubuntu, debian, fedora"
	echo ""
	show_help
fi
