#!/bin/bash
# linux-vul-assessor main entry point
# SPEC: SPEC.md / Phase0_Harness_Engineering.md / Phase1_Normalization_Spec.md
# Version: 0.2
#
# 디버깅:
#   DEBUG=1 ./main.sh audit --profile ubuntu    # 상세 로그
#   DEBUG=2 ./main.sh audit --profile ubuntu    # set -x 트레이스 포함

VERSION="0.2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/assessment.conf"
OUTPUT_BASE="${SCRIPT_DIR}/output"
RUNNER="${SCRIPT_DIR}/runners/shell_runner.sh"
NORMALIZER="${SCRIPT_DIR}/tools/normalizer.py"
JSON_TO_CSV="${SCRIPT_DIR}/tools/json_to_csv.py"
REPORT_GENERATOR="${SCRIPT_DIR}/tools/report_generator.py"
HTML_TO_PDF="${SCRIPT_DIR}/tools/html_to_pdf.py"

# DEBUG 레벨: 0=꺼짐 1=상세로그 2=set -x 트레이스
DEBUG="${DEBUG:-0}"

# DEBUG=2 이면 즉시 set -x
[ "$DEBUG" = "2" ] && set -x

# Basic Colors for Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# =============================================================================
# 로깅 함수
# =============================================================================
function log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
function log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
function log_err()   { echo -e "${RED}[ERROR]${NC} $1"; }
function log_step()  { echo -e "${CYAN}[STEP]${NC} $1"; }

# DEBUG 전용 — DEBUG=0 이면 아무것도 출력하지 않음
function log_debug() {
    [ "$DEBUG" = "0" ] && return
    local ts; ts=$(date '+%H:%M:%S.%3N')
    echo -e "${MAGENTA}[DEBUG ${ts}]${NC} $1" >&2
}

# 타이밍 헬퍼 — 시작 시각(epoch ns) 저장
function _timer_start() {
    [ "$DEBUG" = "0" ] && return
    _TIMER_START=$(date +%s%N 2>/dev/null || date +%s)
}
function _timer_end() {
    [ "$DEBUG" = "0" ] && return
    local end; end=$(date +%s%N 2>/dev/null || date +%s)
    # ns → ms 계산 (ns 지원 환경만)
    if [[ "$_TIMER_START" =~ ^[0-9]{18,}$ ]]; then
        echo $(( (end - _TIMER_START) / 1000000 ))
    else
        echo $(( end - _TIMER_START * 1000 ))
    fi
}

function usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [mode] [options]"
    echo ""
    echo -e "${GREEN}Modes:${NC}"
    echo "  setup       Initialize directory structure and configs"
    echo "  audit       Run vulnerability diagnosis — outputs MD per item"
    echo "  normalize   MD → JSON  (Phase 1 normalization)"
    echo "  csv         JSON → CSV"
    echo "  report      JSON → HTML (compliance report)"
    echo "  pdf         HTML → PDF"
    echo "  all         Full pipeline: audit → MD → JSON → CSV → HTML → PDF"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo "  --profile [os]    Target OS profile: ubuntu, centos, rocky, fedora, oracle"
    echo "  --force           Ignore OS profile mismatch (use with caution)"
    echo "  --upload          Upload results to S3 after report generation"
    echo "  --auto-commit     Automatically commit output changes to Git"
    echo ""
    echo -e "${GREEN}Debug:${NC}"
    echo "  DEBUG=1 $0 ...    상세 디버그 로그 출력"
    echo "  DEBUG=2 $0 ...    set -x 트레이스 포함"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  $0 setup"
    echo "  $0 audit --profile ubuntu"
    echo "  $0 all   --profile ubuntu --upload"
    exit 1
}

# =============================================================================
# Phase 0: OS 감지 및 Profile Safeguard
# =============================================================================
function detect_os() {
    log_debug "detect_os: /etc/os-release 확인 중"
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        log_debug "detect_os: ID=${ID} VERSION_ID=${VERSION_ID:-unknown}"
        echo "${ID,,}"
    else
        log_debug "detect_os: /etc/os-release 없음 → unknown"
        echo "unknown"
    fi
}

function validate_profile() {
    local given_profile="$1"
    local force="$2"
    local actual_os
    actual_os=$(detect_os)

    log_info "Detected OS: ${BLUE}${actual_os}${NC}"
    log_info "Given profile: ${BLUE}${given_profile}${NC}"

    log_debug "validate_profile: given=${given_profile} actual=${actual_os} force=${force}"

    # OS 계열별 정규화 매핑
    #   centos 계열: rocky, almalinux, rhel → centos
    #   oracle 계열: ol (Oracle Linux 7+), oracleserver (Oracle Linux 6) → oracle
    local normalized_actual="$actual_os"
    case "$actual_os" in
        rocky|almalinux|rhel)      normalized_actual="centos" ;;
        ol|oracleserver|"oracle linux") normalized_actual="oracle" ;;
    esac
    local normalized_given="$given_profile"
    case "$given_profile" in
        rocky|almalinux|rhel)      normalized_given="centos" ;;
        ol|oracleserver|"oracle linux") normalized_given="oracle" ;;
    esac

    log_debug "validate_profile: normalized_given=${normalized_given} normalized_actual=${normalized_actual}"

    if [ "$normalized_given" != "$normalized_actual" ]; then
        if [ "$force" == "true" ]; then
            log_warn "Profile mismatch! Given: ${given_profile}, Actual: ${actual_os}. Continuing (--force)."
        else
            log_err "Profile mismatch! Given: ${given_profile}, Actual: ${actual_os}."
            log_err "Use --force to override, or set --profile to '${actual_os}'."
            exit 1
        fi
    else
        log_info "Profile matches detected OS. ✓"
        log_debug "validate_profile: OK"
    fi
}

# =============================================================================
# Git Auto-commit
# =============================================================================
function auto_commit() {
    local message="$1"
    log_debug "auto_commit: 메시지='${message}'"
    if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local status_out
        status_out=$(git -C "$SCRIPT_DIR" status -s)
        log_debug "auto_commit: git status 출력 줄 수=$(echo "$status_out" | wc -l | tr -d ' ')"
        if [[ -n "$status_out" ]]; then
            log_debug "auto_commit: 변경 파일 목록:\n${status_out}"
            git -C "$SCRIPT_DIR" add .
            git -C "$SCRIPT_DIR" commit -m "$message"
            log_info "Auto-committed: $message"
        else
            log_info "No changes to commit."
        fi
    else
        log_warn "Not a git repository. Skipping auto-commit."
    fi
}

# =============================================================================
# Mode: setup
# =============================================================================
function do_setup() {
    log_step "Initializing project structure..."
    log_debug "do_setup: OUTPUT_BASE=${OUTPUT_BASE} SCRIPT_DIR=${SCRIPT_DIR}"
    mkdir -p "${OUTPUT_BASE}"/{json,csv,html,pdf,evidence,logs}
    mkdir -p "${SCRIPT_DIR}"/{runners,tools,config,templates,tests}

    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'EOF'
# linux-vul-assessor configuration
S3_BUCKET="your-audit-results-bucket"
AWS_REGION="ap-northeast-2"
AUDIT_TIMEOUT=30
EOF
        log_info "Created default config: ${CONFIG_FILE}"
    else
        log_debug "do_setup: 기존 config 유지 → ${CONFIG_FILE}"
    fi

    log_info "Setup complete. Directory structure initialized."
}

# =============================================================================
# Mode: audit (Phase 0 핵심 — Runner 기반 격리 실행)
# =============================================================================
function do_audit() {
    local profile=""
    local force="false"
    local commit="false"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --profile)     profile="$2"; shift ;;
            --force)       force="true" ;;
            --auto-commit) commit="true" ;;
            --upload)      ;;   # all 모드에서 전달될 때 무시
        esac
        shift
    done

    if [ -z "$profile" ]; then
        log_err "Profile is required. Use --profile [ubuntu|centos|rocky|fedora|oracle]"
        exit 1
    fi

    log_debug "do_audit: profile=${profile} force=${force} commit=${commit}"
    log_debug "do_audit: DEBUG 레벨=${DEBUG} → Runner에 DEBUG 환경변수 전달됨"

    # Phase 0: Profile Safeguard
    validate_profile "$profile" "$force"

    local script_base="${SCRIPT_DIR}/shell_script/${profile}"
    log_debug "do_audit: script_base=${script_base}"
    if [ ! -d "$script_base" ]; then
        log_err "Script directory not found: ${script_base}"
        exit 1
    fi
    log_debug "do_audit: script_base 존재 확인 ✓ (파일 수=$(ls "${script_base}"/U-*.sh 2>/dev/null | wc -l | tr -d ' ')개)"

    if [ ! -f "$RUNNER" ]; then
        log_err "Runner not found: ${RUNNER}"
        exit 1
    fi
    log_debug "do_audit: runner=${RUNNER} ✓"

    # 타임스탬프 기반 Audit Trail 로그 (ISMS-P 2.10.1)
    local ts
    ts=$(date +'%Y%m%d_%H%M%S')
    local audit_log="${OUTPUT_BASE}/logs/audit_${profile}_${ts}.log"
    mkdir -p "${OUTPUT_BASE}/logs"

    log_step "Starting audit — Profile: ${BLUE}${profile}${NC}"
    log_info "Evidence dir : ${OUTPUT_BASE}/evidence/"
    log_info "Audit trail  : ${audit_log}"
    echo "=== Audit Start: $(date) | User: $(whoami) | Profile: ${profile} ===" >> "$audit_log"
    [ "$DEBUG" != "0" ] && echo "=== DEBUG Level: ${DEBUG} ===" >> "$audit_log"

    local total=0 success=0 failed=0 missing=0
    local audit_wall_start; audit_wall_start=$SECONDS

    # U-01 ~ U-72 순회 (shell_runner.sh 통해 격리 실행 + 증적 자동 저장)
    for i in $(seq -f "%02g" 1 72); do
        local check_id="U-${i}"
        local script_path="${script_base}/${check_id}.sh"

        (( total++ )) || true

        log_debug "do_audit: ─── ${check_id} 시작 (script=${script_path})"

        if [ ! -f "$script_path" ]; then
            # NOT_IMPLEMENTED 마킹
            local ev_dir="${OUTPUT_BASE}/evidence/${check_id}"
            mkdir -p "$ev_dir"
            echo "NOT_IMPLEMENTED" > "${ev_dir}/stdout.txt"
            echo "Script not found: ${script_path}" > "${ev_dir}/stderr.txt"
            echo "0" > "${ev_dir}/exit_code.txt"
            echo "${check_id}: NOT_IMPLEMENTED" >> "$audit_log"
            log_debug "do_audit: ${check_id} → NOT_IMPLEMENTED (스크립트 없음)"
            (( missing++ )) || true
            continue
        fi

        # Phase 0: Runner 통해 격리 실행
        _timer_start
        bash "$RUNNER" \
            --check   "$check_id" \
            --script  "$script_path" \
            --output  "${OUTPUT_BASE}/evidence" \
            --profile "$profile" \
            >> "$audit_log" 2>&1
        local rc=$?
        local elapsed; elapsed=$(_timer_end)

        if [ $rc -eq 0 ]; then
            printf "  ${GREEN}✓${NC} %-8s\n" "$check_id"
            echo "${check_id}: OK (exit=0)" >> "$audit_log"
            log_debug "do_audit: ${check_id} → OK (${elapsed}ms)"
            (( success++ )) || true
        else
            printf "  ${RED}✗${NC} %-8s (exit=%d)\n" "$check_id" "$rc"
            echo "${check_id}: FAIL (exit=${rc})" >> "$audit_log"
            log_debug "do_audit: ${check_id} → FAIL exit=${rc} (${elapsed}ms)"
            # DEBUG=1 이면 stderr 즉시 출력
            if [ "$DEBUG" != "0" ] && [ -f "${OUTPUT_BASE}/evidence/${check_id}/stderr.txt" ]; then
                local stderr_content
                stderr_content=$(cat "${OUTPUT_BASE}/evidence/${check_id}/stderr.txt")
                [ -n "$stderr_content" ] && log_debug "  stderr: ${stderr_content}"
            fi
            (( failed++ )) || true
        fi
    done

    local audit_elapsed=$(( SECONDS - audit_wall_start ))
    echo ""
    echo "=== Audit End: $(date) | OK=${success}, FAIL=${failed}, MISSING=${missing}, TOTAL=${total} ===" >> "$audit_log"
    log_info "Done — ${GREEN}${success} OK${NC} / ${RED}${failed} FAIL${NC} / ${YELLOW}${missing} MISSING${NC} (Total: ${total})"
    log_debug "do_audit: 전체 소요=${audit_elapsed}s (avg=$(( audit_elapsed / (total > 0 ? total : 1) ))s/check)"
    log_debug "do_audit: audit_log → ${audit_log} ($(wc -l < "$audit_log" | tr -d ' ')줄)"

    if [ "$commit" == "true" ]; then
        auto_commit "Audit results: ${profile} - $(date +'%Y-%m-%d %H:%M:%S')"
    fi
}

# =============================================================================
# Mode: normalize  MD → JSON  (Phase 1)
# =============================================================================
function do_normalize() {
    log_step "Phase 1: MD evidence → JSON..."
    log_debug "do_normalize: NORMALIZER=${NORMALIZER}"
    log_debug "do_normalize: evidence_dir=${OUTPUT_BASE}/evidence"

    if [ ! -f "$NORMALIZER" ]; then
        log_err "Normalizer not found: ${NORMALIZER}"
        exit 1
    fi

    _timer_start
    local debug_flag=""
    [ "$DEBUG" != "0" ] && debug_flag="--debug"

    python3 "$NORMALIZER" \
        --evidence-dir "${OUTPUT_BASE}/evidence" \
        --output       "${OUTPUT_BASE}/json/normalized_result.json" \
        $debug_flag
    local rc=$?
    log_debug "do_normalize: python3 exit=${rc}"

    if [ $rc -eq 0 ]; then
        local json_size
        json_size=$(wc -c < "${OUTPUT_BASE}/json/normalized_result.json" 2>/dev/null || echo "?")
        log_info "JSON saved: ${OUTPUT_BASE}/json/normalized_result.json"
        log_debug "do_normalize: JSON 크기=${json_size} bytes"
    else
        log_err "Normalization failed."
        exit 1
    fi
}

# =============================================================================
# Mode: csv  JSON → CSV
# =============================================================================
function do_csv() {
    log_step "JSON → CSV..."
    log_debug "do_csv: JSON_TO_CSV=${JSON_TO_CSV}"

    if [ ! -f "$JSON_TO_CSV" ]; then
        log_err "json_to_csv.py not found: ${JSON_TO_CSV}"
        exit 1
    fi

    local normalized_json="${OUTPUT_BASE}/json/normalized_result.json"
    if [ ! -f "$normalized_json" ]; then
        log_err "normalized_result.json not found. Run 'normalize' first."
        exit 1
    fi
    log_debug "do_csv: input=${normalized_json} ($(wc -c < "$normalized_json") bytes)"

    local ts; ts=$(date +'%Y%m%d_%H%M%S')
    local csv_out="${OUTPUT_BASE}/csv/results_${ts}.csv"
    local debug_flag=""
    [ "$DEBUG" != "0" ] && debug_flag="--debug"

    _timer_start
    python3 "$JSON_TO_CSV" \
        --input  "$normalized_json" \
        --output "$csv_out" \
        $debug_flag
    local rc=$?
    log_debug "do_csv: python3 exit=${rc}"

    if [ $rc -eq 0 ]; then
        log_info "CSV saved: ${csv_out}"
        log_debug "do_csv: CSV 크기=$(wc -c < "$csv_out" 2>/dev/null || echo "?") bytes"
    else
        log_err "CSV conversion failed."
        exit 1
    fi
}

# =============================================================================
# Mode: report  JSON → HTML  (ISMS-P / 전자금융감독규정 매핑 보고서)
# =============================================================================
function do_report() {
    local upload="false"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --upload)      upload="true" ;;
            --profile)     shift ;;
            --force)       ;;
            --auto-commit) ;;
        esac
        shift
    done

    log_step "Generating HTML compliance report..."
    log_debug "do_report: REPORT_GENERATOR=${REPORT_GENERATOR} upload=${upload}"

    if [ ! -f "$REPORT_GENERATOR" ]; then
        log_err "Report generator not found: ${REPORT_GENERATOR}"
        exit 1
    fi

    local normalized_json="${OUTPUT_BASE}/json/normalized_result.json"
    if [ ! -f "$normalized_json" ]; then
        log_err "Normalized result not found. Run 'normalize' mode first."
        exit 1
    fi
    log_debug "do_report: input=${normalized_json}"

    local ts
    ts=$(date +'%Y%m%d_%H%M%S')
    local html_out="${OUTPUT_BASE}/html/report_${ts}.html"
    mkdir -p "${OUTPUT_BASE}/html"
    local debug_flag=""
    [ "$DEBUG" != "0" ] && debug_flag="--debug"

    _timer_start
    python3 "$REPORT_GENERATOR" \
        --input  "$normalized_json" \
        --output "$html_out" \
        $debug_flag
    local rc=$?
    log_debug "do_report: python3 exit=${rc}"

    if [ $rc -eq 0 ]; then
        log_info "Report saved: ${html_out}"
        log_debug "do_report: HTML 크기=$(wc -c < "$html_out" 2>/dev/null || echo "?") bytes"
    else
        log_err "Report generation failed."
        exit 1
    fi

    # S3 업로드 (옵션)
    if [ "$upload" == "true" ]; then
        log_debug "do_report: S3 업로드 시작"
        if [ -f "$CONFIG_FILE" ]; then
            # shellcheck source=/dev/null
            source "$CONFIG_FILE"
        fi
        if [ -z "${S3_BUCKET:-}" ] || [ "$S3_BUCKET" == "your-audit-results-bucket" ]; then
            log_warn "S3_BUCKET not configured in ${CONFIG_FILE}. Skipping upload."
            log_debug "do_report: S3_BUCKET 미설정 → 업로드 스킵"
        else
            log_step "Uploading to S3: ${S3_BUCKET}..."
            log_debug "do_report: s3_uploader.py 호출 (bucket=${S3_BUCKET})"
            python3 "${SCRIPT_DIR}/tools/s3_uploader.py" \
                --path     "${OUTPUT_BASE}" \
                --bucket   "$S3_BUCKET" \
                --hostname "$(hostname)" \
                --region   "${AWS_REGION:-ap-northeast-2}"
        fi
    fi
}

# =============================================================================
# Mode: pdf  HTML → PDF
# =============================================================================
function do_pdf() {
    log_step "HTML → PDF..."
    log_debug "do_pdf: HTML_TO_PDF=${HTML_TO_PDF}"

    if [ ! -f "$HTML_TO_PDF" ]; then
        log_err "html_to_pdf.py not found: ${HTML_TO_PDF}"
        exit 1
    fi

    # 가장 최신 HTML 보고서 찾기
    local html_file
    html_file=$(ls -t "${OUTPUT_BASE}/html"/report_*.html 2>/dev/null | head -1)
    if [ -z "$html_file" ]; then
        log_err "No HTML report found. Run 'report' first."
        exit 1
    fi
    log_debug "do_pdf: 대상 HTML=${html_file} ($(wc -c < "$html_file" 2>/dev/null || echo "?") bytes)"

    local ts; ts=$(date +'%Y%m%d_%H%M%S')
    local pdf_out="${OUTPUT_BASE}/pdf/report_${ts}.pdf"
    mkdir -p "${OUTPUT_BASE}/pdf"
    local debug_flag=""
    [ "$DEBUG" != "0" ] && debug_flag="--debug"

    _timer_start
    python3 "$HTML_TO_PDF" \
        --input  "$html_file" \
        --output "$pdf_out" \
        $debug_flag
    local rc=$?
    log_debug "do_pdf: python3 exit=${rc}"

    if [ $rc -eq 0 ]; then
        log_info "PDF saved: ${pdf_out}"
        log_debug "do_pdf: PDF 크기=$(wc -c < "$pdf_out" 2>/dev/null || echo "?") bytes"
    else
        log_err "PDF conversion failed."
        exit 1
    fi
}

# =============================================================================
# Mode: all  (Full pipeline: audit → MD → JSON → CSV → HTML → PDF)
# =============================================================================
function do_all() {
    log_step "=== Full Pipeline: audit → MD → JSON → CSV → HTML → PDF ==="
    log_debug "do_all: args=$*"
    local wall_start=$SECONDS
    do_audit "$@"
    log_debug "do_all: audit 완료 (누적 $(( SECONDS - wall_start ))s)"
    do_normalize
    log_debug "do_all: normalize 완료 (누적 $(( SECONDS - wall_start ))s)"
    do_csv
    log_debug "do_all: csv 완료 (누적 $(( SECONDS - wall_start ))s)"
    do_report "$@"
    log_debug "do_all: report 완료 (누적 $(( SECONDS - wall_start ))s)"
    do_pdf
    log_debug "do_all: 전체 파이프라인 완료 — 총 소요: $(( SECONDS - wall_start ))s"
}

# =============================================================================
# Main
# =============================================================================
if [ $# -lt 1 ]; then usage; fi

log_debug "main: 시작 — VERSION=${VERSION} PID=$$ USER=$(whoami) PWD=$(pwd)"
log_debug "main: 전달된 인자: $*"
log_debug "main: CONFIG_FILE=${CONFIG_FILE} (존재=$([ -f "$CONFIG_FILE" ] && echo Y || echo N))"

MODE=$1
shift

case "$MODE" in
    setup)     do_setup ;;
    audit)     do_audit "$@" ;;
    normalize) do_normalize ;;
    csv)       do_csv ;;
    report)    do_report "$@" ;;
    pdf)       do_pdf ;;
    all)       do_all "$@" ;;
    -h|--help) usage ;;
    *)         log_err "Unknown mode: $MODE"; usage ;;
esac

log_debug "main: 완료 — MODE=${MODE} exit=0"
