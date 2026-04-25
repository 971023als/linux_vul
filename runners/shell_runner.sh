#!/bin/bash
# runners/shell_runner.sh
# Purpose: Safely execute individual U-xx.sh scripts and capture results

# --- Initialization ---
CHECK_ID=""
SCRIPT_PATH=""
# Default to output/evidence in the project root (one level up from runners/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$(cd "$SCRIPT_DIR/../output/evidence" && pwd)"
EXIT_CODE=0

# --- Help Function ---
function usage() {
    echo "Usage: $0 --check ID --script PATH [--output DIR]"
    exit 1
}

# --- Parse Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --check) CHECK_ID="$2"; shift ;;
        --script) SCRIPT_PATH="$2"; shift ;;
        --output) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

if [ -z "$CHECK_ID" ] || [ -z "$SCRIPT_PATH" ]; then
    usage
fi

# --- Prepare Evidence Directory ---
ITEM_EVIDENCE_DIR="$OUTPUT_DIR/$CHECK_ID"
mkdir -p "$ITEM_EVIDENCE_DIR"

STDOUT_FILE="$ITEM_EVIDENCE_DIR/stdout.txt"
STDERR_FILE="$ITEM_EVIDENCE_DIR/stderr.txt"
EXIT_CODE_FILE="$ITEM_EVIDENCE_DIR/exit_code.txt"

# --- Execute Script ---
if [ -f "$SCRIPT_PATH" ]; then
    # Run script and capture stdout/stderr separately
    bash "$SCRIPT_PATH" > "$STDOUT_FILE" 2> "$STDERR_FILE"
    EXIT_CODE=$?
    echo "$EXIT_CODE" > "$EXIT_CODE_FILE"
    
    # Also output stdout to console so the calling vul.sh can capture it
    cat "$STDOUT_FILE"
else
    echo "ERROR: Script $SCRIPT_PATH not found" > "$STDERR_FILE"
    echo "1" > "$EXIT_CODE_FILE"
    exit 1
fi

exit $EXIT_CODE
