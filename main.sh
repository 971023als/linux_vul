#!/bin/bash
# main.sh
# -----------------------------------------------------------------------------
# [Main Runner] Linux 인프라 취약점 진단 통합 실행기
#               + DBMS 취약점 진단 모듈 (dbm 하위 명령)
# -----------------------------------------------------------------------------
# 사용법:
#   ./main.sh                              # Linux OS 자동 감지 진단
#   ./main.sh dbm setup                    # DBMS 모듈 초기화
#   ./main.sh dbm audit --profile oracle --dry-run
#   ./main.sh dbm audit --profile mssql --check DBM-001 --dry-run
#   ./main.sh dbm report
#   ./main.sh dbm verify --profile oracle --check DBM-001
# -----------------------------------------------------------------------------

set -u

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# dbm 하위 명령 처리 (최상단 분기 – 기존 Linux 로직과 완전 격리)
# =============================================================================
if [[ "${1:-}" == "dbm" ]]; then
    shift  # "dbm" 제거

    # ------------------------------------------------------------------
    # 허용 profile 목록
    # ------------------------------------------------------------------
    ALLOWED_PROFILES=("cloud_dbms" "oracle" "mssql" "mysql" "postgresql" "altibase" "tibero")

    DBM_SUBCMD="${1:-}"
    if [[ -z "$DBM_SUBCMD" ]]; then
        echo -e "${RED}[dbm] 하위 명령이 필요합니다. (setup|audit|report|verify)${NC}" >&2
        exit 1
    fi
    shift  # subcommand 제거

    # ------------------------------------------------------------------
    # dbm setup
    # ------------------------------------------------------------------
    if [[ "$DBM_SUBCMD" == "setup" ]]; then
        echo -e "${CYAN}[dbm setup] DBMS 모듈 초기화 시작...${NC}"
        "${SCRIPT_DIR_ROOT}/runners/dbms_runner.sh" --action setup
        exit $?
    fi

    # ------------------------------------------------------------------
    # dbm report
    # ------------------------------------------------------------------
    if [[ "$DBM_SUBCMD" == "report" ]]; then
        echo -e "${CYAN}[dbm report] 보고서 생성 시작...${NC}"
        python3 "${SCRIPT_DIR_ROOT}/tools/dbm_json_to_csv.py"
        python3 "${SCRIPT_DIR_ROOT}/tools/dbm_json_to_html.py"
        python3 "${SCRIPT_DIR_ROOT}/tools/dbm_html_to_pdf.py"
        exit $?
    fi

    # ------------------------------------------------------------------
    # dbm audit / dbm verify – 공통 인자 파싱
    # ------------------------------------------------------------------
    if [[ "$DBM_SUBCMD" != "audit" && "$DBM_SUBCMD" != "verify" ]]; then
        echo -e "${RED}[dbm] 알 수 없는 하위 명령: ${DBM_SUBCMD}${NC}" >&2
        echo -e "사용 가능: setup | audit | report | verify" >&2
        exit 1
    fi

    DBM_PROFILE=""
    DBM_CHECK=""
    DBM_DRY_RUN=false
    DBM_CONNECT=false
    DBM_CONNECT_MODE="readonly"
    DBM_DB_HOST=""
    DBM_DB_USER=""
    DBM_DB_PORT=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --profile)
                DBM_PROFILE="${2:-}"
                shift 2
                ;;
            --check)
                DBM_CHECK="${2:-}"
                shift 2
                ;;
            --dry-run)
                DBM_DRY_RUN=true
                shift
                ;;
            --connect)
                DBM_CONNECT=true
                shift
                ;;
            --connect-mode)
                DBM_CONNECT_MODE="${2:-readonly}"
                shift 2
                ;;
            --db-host)
                DBM_DB_HOST="${2:-}"
                shift 2
                ;;
            --db-user)
                DBM_DB_USER="${2:-}"
                shift 2
                ;;
            --db-port)
                DBM_DB_PORT="${2:-}"
                shift 2
                ;;
            --apply|--remediate|--sqlplus|--sqlcmd|--mysql|--psql|--jdbc|--odbc)
                echo -e "${RED}[dbm] 지원하지 않는 옵션: $1${NC}" >&2
                exit 1
                ;;
            *)
                echo -e "${RED}[dbm] 알 수 없는 옵션: $1${NC}" >&2
                exit 1
                ;;
        esac
    done

    # --connect-mode 유효성 확인
    if [[ "$DBM_CONNECT" == "true" && "$DBM_CONNECT_MODE" != "readonly" ]]; then
        echo -e "${RED}[dbm] --connect-mode '${DBM_CONNECT_MODE}' 는 허용되지 않습니다.${NC}" >&2
        echo -e "Phase 1 허용 모드: readonly" >&2
        exit 1
    fi

    # --profile 필수 확인
    if [[ -z "$DBM_PROFILE" ]]; then
        echo -e "${RED}[dbm ${DBM_SUBCMD}] --profile 이 필요합니다.${NC}" >&2
        echo -e "허용 profile: ${ALLOWED_PROFILES[*]}" >&2
        exit 1
    fi

    # profile 유효성 확인
    PROFILE_VALID=false
    for p in "${ALLOWED_PROFILES[@]}"; do
        if [[ "$p" == "$DBM_PROFILE" ]]; then
            PROFILE_VALID=true
            break
        fi
    done
    if [[ "$PROFILE_VALID" != "true" ]]; then
        echo -e "${RED}[dbm] 허용되지 않는 profile: '${DBM_PROFILE}'${NC}" >&2
        echo -e "허용 profile 목록: ${ALLOWED_PROFILES[*]}" >&2
        exit 1
    fi

    # --connect 모드 처리: SQL 커넥터 실행 후 종료
    if [[ "$DBM_CONNECT" == "true" ]]; then
        echo -e "${CYAN}[dbm connect] profile=${DBM_PROFILE} mode=${DBM_CONNECT_MODE}${NC}"
        CONNECTOR="${SCRIPT_DIR_ROOT}/runners/connectors/${DBM_PROFILE}_connector.sh"
        if [[ ! -f "$CONNECTOR" ]]; then
            echo -e "${RED}[dbm connect] 커넥터 없음: ${CONNECTOR}${NC}" >&2
            exit 1
        fi
        CONN_ARGS=(
            "--mode" "$DBM_CONNECT_MODE"
            "--profile" "$DBM_PROFILE"
        )
        [[ -n "$DBM_DB_HOST" ]] && CONN_ARGS+=("--db-host" "$DBM_DB_HOST")
        [[ -n "$DBM_DB_USER" ]] && CONN_ARGS+=("--db-user" "$DBM_DB_USER")
        [[ -n "$DBM_DB_PORT" ]] && CONN_ARGS+=("--db-port" "$DBM_DB_PORT")
        bash "$CONNECTOR" "${CONN_ARGS[@]}"
        exit $?
    fi

    # runner 호출
    echo -e "${CYAN}[dbm ${DBM_SUBCMD}] profile=${DBM_PROFILE} check=${DBM_CHECK:-ALL} dry_run=${DBM_DRY_RUN}${NC}"

    RUNNER_ARGS=(
        "--action" "audit"
        "--profile" "$DBM_PROFILE"
    )
    [[ -n "$DBM_CHECK" ]]      && RUNNER_ARGS+=("--check" "$DBM_CHECK")
    [[ "$DBM_DRY_RUN" == "true" ]] && RUNNER_ARGS+=("--dry-run")

    "${SCRIPT_DIR_ROOT}/runners/dbms_runner.sh" "${RUNNER_ARGS[@]}"
    exit $?
fi

# =============================================================================
# 기존 Linux 진단 로직 (변경 없음)
# =============================================================================
echo -e "${YELLOW}==================================================${NC}"
echo -e "${YELLOW}   Linux Infrastructure Security Diagnostics   ${NC}"
echo -e "${YELLOW}==================================================${NC}"

# 1. OS 감지
if [ -f /etc/os-release ]; then
    OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    case "$OS_ID" in
        ubuntu)   PROFILE="ubuntu" ;;
        centos)   PROFILE="centos" ;;
        ol|oracle) PROFILE="oracle" ;;
        rhel)     PROFILE="centos" ;; # RHEL은 CentOS 프로필 호환
        *)        echo -e "${RED}[Error] 지원하지 않는 OS입니다 ($OS_ID).${NC}"; exit 1 ;;
    esac
else
    echo -e "${RED}[Error] /etc/os-release 파일을 찾을 수 없습니다.${NC}"
    exit 1
fi

echo -e "${GREEN}[Info] 감지된 OS 프로필: $PROFILE${NC}"

# 2. 리포트 저장소 준비
DATE=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname)
REPORT_DIR="reports"
REPORT_FILE="${REPORT_DIR}/Result_${HOSTNAME}_${DATE}.md"

mkdir -p "$REPORT_DIR"

# 3. 리포트 헤더 작성
cat << __MD_EOF__ > "$REPORT_FILE"
# Linux 인프라 보안 진단 통합 리포트

| 정보 | 내용 |
|------|------|
| 대상서버 | ${HOSTNAME} |
| 운영체제 | ${OS_ID} |
| 진단일시 | $(date '+%Y-%m-%d %H:%M:%S') |
| 진단프로필 | ${PROFILE} |

---

__MD_EOF__

# 4. 진단 항목 일괄 실행
SCRIPT_DIR="shell_script/${PROFILE}"

if [ ! -d "$SCRIPT_DIR" ]; then
    echo -e "${RED}[Error] 스크립트 디렉터리가 존재하지 않습니다: $SCRIPT_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}[Proceed] 보안 진단을 시작합니다...${NC}"

for i in $(seq -f "%02g" 1 72); do
    SCRIPT="${SCRIPT_DIR}/U-${i}.sh"
    if [ -f "$SCRIPT" ]; then
        echo -n "[$(date +%H:%M:%S)] U-${i} 수행 중..."
        # 스크립트 실행 및 결과를 리포트 파일에 추가
        bash "$SCRIPT" >> "$REPORT_FILE" 2>/dev/null
        echo -e "\r[$(date +%H:%M:%S)] ${GREEN}U-${i} 완료${NC}        "
    fi
done

echo -e "${YELLOW}==================================================${NC}"
echo -e "${GREEN}[Success] 진단이 완료되었습니다.${NC}"
echo -e "${GREEN}[Report] 통합 리포트: ${REPORT_FILE}${NC}"
echo -e "${YELLOW}==================================================${NC}"
