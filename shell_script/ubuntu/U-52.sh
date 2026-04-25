#!/bin/bash
# shell_script/ubuntu/U-52.sh
# -----------------------------------------------------------------------------
# [U-52] 동일한 GID 금지
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.1(사용자 식별)
# - 목적: 그룹 ID(GID)의 중복을 방지하여 그룹별 권한 할당의 명확성 및 책임 추적성 확보
# -----------------------------------------------------------------------------

set -u

CODE="U-52"
CATEGORY="계정 관리"
RISK="하"
ITEM="동일한 GID 금지"

RESULT="양호"
STATUS=""

# 1. 중복된 GID 검색 (/etc/group)
DUPLICATE_GIDS=$(awk -F: '{print $3}' /etc/group | sort | uniq -d)

if [ -z "$DUPLICATE_GIDS" ]; then
    STATUS="중복된 GID가 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="다음 GID들이 중복 사용되고 있습니다:\n"
    for GID_VAL in $DUPLICATE_GIDS; do
        GROUPS=$(awk -F: -v gid="$GID_VAL" '$3 == gid { print $1 }' /etc/group | xargs)
        STATUS="${STATUS}GID ${GID_VAL}: ${GROUPS}\n"
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
| 대응방안 | 중복된 GID를 가진 그룹의 GID를 고유한 값으로 변경 |

__MD_EOF__
