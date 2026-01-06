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
  -h, --help        Show this help message

Distros:
  ubuntu            Test on Ubuntu 24.04 LTS
  debian            Test on Debian Bookworm
  fedora            Test on Fedora latest

Examples:
  $0 ubuntu                    # Minimal test on Ubuntu (default)
  $0 --full ubuntu             # Full install test on Ubuntu
  $0 --dry-run debian          # Dry-run test on Debian (safe, no changes)
  $0 --dry-run --verbose --all # Verbose dry-run on all distros
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

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN="-n"
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -f|--full)
            FULL_MODE="-f"
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
    local base_setup=""
    local setup_flags="-y"  # Always use auto-yes for non-interactive testing

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
    # Replicates real scenario: regular user runs 'sudo ./setup' on fresh machine
    # Script runs as root via sudo, detects real user via $SUDO_USER
    # Mount dotfiles to staging dir, then copy to user's home so setup can source
    # installers/*.sh and read packages.yaml (git clone happens after sourcing)
    local setup_cmd="$base_setup && \
        useradd -m -s /bin/bash testuser && \
        echo 'testuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/testuser && \
        cp -r /tmp/dotfiles-src /home/testuser/.dotfiles && \
        chown -R testuser:testuser /home/testuser/.dotfiles && \
        su - testuser -c \"sudo bash /home/testuser/.dotfiles/setup $setup_flags\""

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
                cp -r /tmp/dotfiles-src /home/testuser/.dotfiles && \
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
        } > "$logfile"

        print_info "Running test... (output redirected to log)"

        if docker run --rm \
            -v "$DOTFILES_DIR:/tmp/dotfiles-src:ro" \
            "$image" \
            bash -c "$setup_cmd" >> "$logfile" 2>&1; then
            {
                echo ""
                echo "════════════════════════════════════════"
                echo "Test completed successfully at $(date)"
            } >> "$logfile"
            print_success "$distro test passed"
            print_info "Full log: $logfile"
            return 0
        else
            {
                echo ""
                echo "════════════════════════════════════════"
                echo "Test failed at $(date)"
            } >> "$logfile"
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
