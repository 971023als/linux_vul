#!/bin/bash
# shell_script/centos/U-49.sh
# -----------------------------------------------------------------------------
# [U-49] 불필요한 계정 제거 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.1(사용자 식별)
# - 목적: 사용하지 않는 기본 서비스 계정을 제거하여 잠재적인 침투 경로 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-49"
CATEGORY="계정 관리"
RISK="하"
ITEM="불필요한 계정 제거"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 불필요한 기본 계정 리스트
UNUSED_ACCOUNTS=("lp" "uucp" "nuucp" "games" "sync" "shutdown" "halt")
FOUND_ACCOUNTS=""

for ACC in "${UNUSED_ACCOUNTS[@]}"; do
    if getent passwd "$ACC" > /dev/null; then
        FOUND_ACCOUNTS="${FOUND_ACCOUNTS}${ACC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="불필요한 기본 계정이 존재하지 않습니다."
else
    STATUS="불필요한 기본 계정이 존재합니다: ${FOUND_ACCOUNTS}"
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
else
    STATUS="[취약] $STATUS (업무상 필요 여부 확인 후 삭제 권고)"
fi

# ==== 표준 출력 (Markdown) ====
cat << __MD_EOF__
# ${CODE}: ${ITEM}

| 항목 | 내용 |
|------|------|
| 분류 | ${CATEGORY} |
| 코드 | ${CODE} |
| 위험도 | ${RISK} |
| 진단항목 | ${ITEM} |
| 진단결과 | **${RESULT}** |
| 현황 | ${STATUS} |
| 대응방안 | userdel [계정명] 명령으로 불필요한 계정 삭제 |

__MD_EOF__
