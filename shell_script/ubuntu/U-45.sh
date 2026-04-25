#!/bin/bash
# shell_script/ubuntu/U-45.sh
# -----------------------------------------------------------------------------
# [U-45] 동일한 UID 금지
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.1(사용자 식별)
# - 목적: 계정 간 UID 중복을 방지하여 사용자 식별 및 책임 추적성 확보
# -----------------------------------------------------------------------------

set -u

CODE="U-45"
CATEGORY="계정 관리"
RISK="상"
ITEM="동일한 UID 금지"

RESULT="양호"
STATUS=""

# 1. 중복된 UID 검색
DUPLICATE_UIDS=$(awk -F: '{print $3}' /etc/passwd | sort | uniq -d)

if [ -z "$DUPLICATE_UIDS" ]; then
    STATUS="중복된 UID가 존재하지 않습니다."
else
    RESULT="취약"
    # 어떤 계정들이 중복인지 상세 리포팅
    STATUS="다음 UID들이 중복 사용되고 있습니다:\n"
    for UID_VAL in $DUPLICATE_UIDS; do
        ACCOUNTS=$(awk -F: -v uid="$UID_VAL" '$3 == uid { print $1 }' /etc/passwd | xargs)
        STATUS="${STATUS}UID ${UID_VAL}: ${ACCOUNTS}\n"
    done
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
| 대응방안 | 중복된 UID를 가진 계정의 UID를 고유한 값으로 변경 |

__MD_EOF__
