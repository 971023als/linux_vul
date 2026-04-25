#!/bin/bash
# shell_script/ubuntu/U-44.sh
# -----------------------------------------------------------------------------
# [U-44] root 이외의 UID가 0인 계정 존재 여부
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: root 권한(UID 0)을 가진 다른 계정을 색출하여 비인가된 슈퍼유저 권한 획득 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-44"
CATEGORY="계정 관리"
RISK="상"
ITEM="root 이외의 UID가 0인 계정 존재 여부"

RESULT="양호"
STATUS=""

# 1. UID가 0인 계정 리스트 추출 (root 제외)
EXTRA_UID0=$(awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd)

if [ -z "$EXTRA_UID0" ]; then
    STATUS="root 이외에 UID가 0인 계정이 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="UID가 0인 추가 계정이 발견되었습니다: ${EXTRA_UID0}"
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
| 대응방안 | 발견된 계정의 UID를 변경하거나 불필요한 경우 삭제 |

__MD_EOF__
