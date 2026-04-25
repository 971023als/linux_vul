#!/bin/bash
# linux-vul-assessor main entry point
# Version: 0.1

VERSION="0.1"
CONFIG_FILE="config/assessment.conf"
OUTPUT_BASE="output"

# Basic Colors for Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [mode] [options]"
    echo ""
    echo -e "${GREEN}Modes:${NC}"
    echo "  setup       Initialize directory structure and configs"
    echo "  audit       Run vulnerability diagnosis (system check only)"
    echo "  report      Generate CSV/HTML/PDF reports from JSON results"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo "  --profile [os]    Target OS (ubuntu, centos, rocky, etc.)"
    echo "  --force           Ignore OS profile mismatch warning"
    exit 1
}

function log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
function log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
function log_err()  { echo -e "${RED}[ERROR]${NC} $1"; }

# --- OS Detection Logic (Harness Safeguard) ---
function detect_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

function validate_profile() {
    local GIVEN_PROFILE=$1
    local ACTUAL_OS=$(detect_os)
    local FORCE=$2

    log_info "Detected OS: ${BLUE}$ACTUAL_OS${NC}"

    if [ "$GIVEN_PROFILE" != "$ACTUAL_OS" ]; then
        if [ "$FORCE" == "true" ]; then
            log_warn "Profile mismatch! Given: $GIVEN_PROFILE, Actual: $ACTUAL_OS. Continuing due to --force."
        else
            log_err "Profile mismatch! Given: $GIVEN_PROFILE, Actual: $ACTUAL_OS."
            log_err "To proceed anyway, use --force"
            exit 1
        fi
    else
        log_info "Profile matches detected OS."
    fi
}

# --- Mode Handlers ---

function do_setup() {
    log_info "Initializing project structure..."
    mkdir -p output/{json,csv,html,pdf,evidence,logs} runners tools config templates tests
    log_info "Setup complete."
}

function do_audit() {
    local PROFILE=""
    local FORCE="false"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --profile) PROFILE="$2"; shift ;;
            --force) FORCE="true" ;;
        esac
        shift
    done

    if [ -z "$PROFILE" ]; then
        log_err "Profile is required for audit. Use --profile [os]"
        exit 1
    fi

    # Run Safeguard
    validate_profile "$PROFILE" "$FORCE"

    log_info "Starting audit for profile: $PROFILE"
    # Execute actual audit logic (e.g., shell_scirpt/$PROFILE/vul.sh)
    # cd shell_scirpt/$PROFILE && bash vul.sh
}

# --- Main Logic ---

if [ $# -lt 1 ]; then usage; fi

MODE=$1
shift

case "$MODE" in
    setup)     do_setup ;;
    audit)     do_audit "$@" ;;
    *)         usage ;;
esac
