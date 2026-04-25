#!/bin/bash
# main.sh
# -----------------------------------------------------------------------------
# [Main Runner] Linux 인프라 취약점 진단 통합 실행기
# -----------------------------------------------------------------------------
# - 목적: OS 자동 감지 및 전 항목 일괄 진단 수행, 통합 Markdown 리포트 생성
# -----------------------------------------------------------------------------

set -u

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
