#!/bin/bash
# runners/connectors/connector_base.sh
# -----------------------------------------------------------------------------
# [Connector Base] Read-only SQL 접속 공통 라이브러리
#
# 원칙:
#   - DIRECT_DB_ACCESS=true 시에도 SELECT/SHOW/DESC/EXPLAIN/\\d 등
#     읽기 전용 쿼리만 허용한다.
#   - 쓰기 쿼리 (INSERT/UPDATE/DELETE/DROP/CREATE/ALTER/GRANT/REVOKE/EXEC)는
#     쿼리 레벨 안전 검사로 차단한다.
#   - 연결 정보(패스워드)는 환경변수 또는 ~/.pgpass / wallets 등 표준
#     자격증명 저장소에서 읽는다. 명령행 패스워드 인자 금지.
#   - 모든 접속 시도와 결과를 output/logs/connector_YYYYMMDD_HHMMSS.log에 기록한다.
# -----------------------------------------------------------------------------

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${RUNNER_DIR}/../.." && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

CONN_MODE="readonly"
CONN_PROFILE=""
DB_HOST=""
DB_USER=""
DB_PORT=""
DB_NAME=""

# 읽기 전용 쿼리 안전 검사
# return 0 = 안전 (READ), 1 = 위험 (WRITE)
is_readonly_query() {
    local query="$1"
    # 대문자 변환 후 위험 키워드 확인 (단어 경계)
    local upper
    upper=$(echo "$query" | tr '[:lower:]' '[:upper:]' | tr -d '\n')
    # 허용: SELECT, SHOW, DESCRIBE, DESC, EXPLAIN, WITH (CTE), \\d, \\l, \\dt 등
    # 차단: INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, GRANT, REVOKE,
    #        TRUNCATE, EXECUTE, EXEC, CALL, MERGE, UPSERT, BEGIN TRAN (쓰기)
    local BLOCK_PATTERN='(^|[[:space:]|;])(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|GRANT|REVOKE|TRUNCATE|EXECUTE|EXEC[[:space:]]|CALL[[:space:]]|MERGE|UPSERT|DBCC|BULK[[:space:]]INSERT|LOAD[[:space:]]DATA|INTO[[:space:]]OUTFILE|xp_cmdshell)'
    if echo "$upper" | grep -qiP "$BLOCK_PATTERN" 2>/dev/null; then
        return 1
    fi
    return 0
}

# 연결 로그 초기화
init_connector_log() {
    local ts
    ts=$(date +%Y%m%d_%H%M%S)
    mkdir -p "${PROJECT_DIR}/output/logs"
    CONN_LOG="${PROJECT_DIR}/output/logs/connector_${CONN_PROFILE}_${ts}.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Connector started: profile=${CONN_PROFILE} mode=${CONN_MODE}" >> "$CONN_LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] host=${DB_HOST} user=${DB_USER} port=${DB_PORT}" >> "$CONN_LOG"
}

# 연결 성공/실패 로그
log_conn_result() {
    local status="$1" msg="${2:-}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${status}: ${msg}" >> "${CONN_LOG:-/dev/null}"
    if [[ "$status" == "SUCCESS" ]]; then
        echo -e "${GREEN}[connector] ✅ ${msg}${NC}"
    else
        echo -e "${RED}[connector] ❌ ${msg}${NC}" >&2
    fi
}

# 인자 파싱 (공통)
parse_connector_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --mode)     CONN_MODE="${2:-readonly}";  shift 2 ;;
            --profile)  CONN_PROFILE="${2:-}";       shift 2 ;;
            --db-host)  DB_HOST="${2:-}";            shift 2 ;;
            --db-user)  DB_USER="${2:-}";            shift 2 ;;
            --db-port)  DB_PORT="${2:-}";            shift 2 ;;
            --db-name)  DB_NAME="${2:-}";            shift 2 ;;
            *)          shift ;;
        esac
    done
}

# 사전 조건 확인
preflight_check() {
    local tool="$1"
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${YELLOW}[connector] ${tool} 클라이언트가 설치되어 있지 않습니다.${NC}" >&2
        echo -e "${YELLOW}[connector] 증적 파일 기반(Phase 0) 분석은 --connect 없이 가능합니다.${NC}" >&2
        return 1
    fi
    if [[ "$CONN_MODE" != "readonly" ]]; then
        echo -e "${RED}[connector] CONN_MODE=${CONN_MODE} – readonly만 허용됩니다.${NC}" >&2
        return 1
    fi
    return 0
}

# 증적 저장 디렉터리
evidence_dir() {
    local check_id="${1:-CONN}"
    local dir="${PROJECT_DIR}/input/evidence/dbms/${CONN_PROFILE}"
    mkdir -p "$dir"
    echo "$dir"
}
