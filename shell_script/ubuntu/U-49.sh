#!/bin/bash
# shell_script/ubuntu/U-49.sh
# -----------------------------------------------------------------------------
# [U-49] 불필요한 계정 제거
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 사용하지 않는 시스템 계정(lp, uucp 등)을 제거하여 계정 도용 위험 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-49"
CATEGORY="계정 관리"
RISK="하"
ITEM="불필요한 계정 제거"

RESULT="양호"
STATUS=""

# 1. 점검 대상 불필요 계정 리스트
# lp, uucp, nuucp 등 기본적으로 사용하지 않는 계정들
UNNECESSARY_ACCOUNTS=("lp" "uucp" "nuucp" "games")
VULN_ACCOUNTS=""

for ACCOUNT in "${UNNECESSARY_ACCOUNTS[@]}"; do
    if getent passwd "$ACCOUNT" >/dev/null 2>&1; then
        VULN_ACCOUNTS="${VULN_ACCOUNTS}${ACCOUNT} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="불필요한 시스템 계정이 존재하지 않습니다."
else
    STATUS="불필요한 계정이 발견되었습니다: ${VULN_ACCOUNTS}(사용 여부 확인 후 삭제 권고)"
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
else
    STATUS="[취약] $STATUS"
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
| 대응방안 | 사용하지 않는 시스템 계정 삭제 (userdel [ACCOUNT]) |

__MD_EOF__
