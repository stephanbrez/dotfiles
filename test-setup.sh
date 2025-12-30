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
  -i, --interactive Run container interactively (for debugging)
  -a, --all         Test all supported distros
  -h, --help        Show this help message

Distros:
  ubuntu            Test on Ubuntu 24.04 LTS
  debian            Test on Debian Bookworm
  fedora            Test on Fedora latest

Examples:
  $0 ubuntu                    # Full test on Ubuntu (will install packages!)
  $0 --dry-run debian          # Dry-run test on Debian (safe, no changes)
  $0 --dry-run --all           # Dry-run test on all distros
  $0 -i ubuntu                 # Interactive Ubuntu container for debugging

Logs:
  Logs are stored in test-logs/ with format: {distro}_{timestamp}.log
  To view the latest log: tail -f test-logs/ubuntu_*.log | tail -1
EOF
    exit 0
}

# Parse arguments
DRY_RUN=""
INTERACTIVE=""
TEST_ALL=""
DISTRO=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN="-n"
            shift
            ;;
        -i|--interactive)
            INTERACTIVE="yes"
            shift
            ;;
        -a|--all)
            TEST_ALL="yes"
            shift
            ;;
        -h|--help)
            show_help
            ;;
        ubuntu|debian|fedora)
            DISTRO="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# ─── Test function for a single distro ───
test_distro() {
    local distro=$1
    local image=""
    local setup_cmd=""
    local setup_flags="-y"  # Always use auto-yes for non-interactive testing

    # Add dry-run flag if requested
    [[ -n "$DRY_RUN" ]] && setup_flags="$setup_flags -n"

    case $distro in
        ubuntu)
            image="ubuntu:24.04"
            setup_cmd="apt-get update && apt-get install -y sudo lsb-release && cd /root/.dotfiles && bash setup $setup_flags"
            ;;
        debian)
            image="debian:bookworm"
            setup_cmd="apt-get update && apt-get install -y sudo lsb-release && cd /root/.dotfiles && bash setup $setup_flags"
            ;;
        fedora)
            image="fedora:latest"
            setup_cmd="cd /root/.dotfiles && bash setup $setup_flags"
            ;;
        *)
            print_error "Unknown distro: $distro"
            return 1
            ;;
    esac

    local logfile="$LOG_DIR/${distro}_${TIMESTAMP}.log"

    print_header "Testing on $distro ($image)"
    print_info "Log file: $logfile"

    if [[ -n "$INTERACTIVE" ]]; then
        print_warning "Starting interactive container..."
        print_warning "Run 'cd /root/.dotfiles && bash setup -n' to test"
        docker run --rm -it \
            -v "$DOTFILES_DIR:/root/.dotfiles:ro" \
            "$image" \
            bash
    else
        echo "Starting test at $(date)" > "$logfile"
        echo "Distro: $distro" >> "$logfile"
        echo "Image: $image" >> "$logfile"
        echo "Command: $setup_cmd" >> "$logfile"
        echo "════════════════════════════════════════" >> "$logfile"
        echo "" >> "$logfile"

        print_info "Running test... (output redirected to log)"

        if docker run --rm \
            -v "$DOTFILES_DIR:/root/.dotfiles:ro" \
            "$image" \
            bash -c "$setup_cmd" >> "$logfile" 2>&1; then
            echo "" >> "$logfile"
            echo "════════════════════════════════════════" >> "$logfile"
            echo "Test completed successfully at $(date)" >> "$logfile"
            print_success "$distro test passed"
            print_info "Full log: $logfile"
            return 0
        else
            echo "" >> "$logfile"
            echo "════════════════════════════════════════" >> "$logfile"
            echo "Test failed at $(date)" >> "$logfile"
            print_error "$distro test failed"
            print_error "Check log for details: $logfile"
            return 1
        fi
    fi
}

# ─── Main ───

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
fi

print_header "Setup Script Docker Test"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Log directory: $LOG_DIR"
echo "Dry-run mode: ${DRY_RUN:-disabled}"
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
