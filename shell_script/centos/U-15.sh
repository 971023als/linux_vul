#!/bin/bash
# shell_script/centos/U-15.sh
# -----------------------------------------------------------------------------
# [U-15] world writable 파일 점검 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 누구나 수정 가능한(World Writable) 파일을 제거하여 비인가된 시스템 변조 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-15"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="world writable 파일 점검"

RESULT="양호"
STATUS=""

# 1. World Writable 파일 검색 (가상 파일시스템 제외)
WW_FILES=$(find / \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o -type f -perm -2 -print 2>/dev/null | head -n 20)

if [ -z "$WW_FILES" ]; then
    STATUS="World Writable 파일이 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="World Writable 파일이 발견되었습니다:\n$WW_FILES"
    if [ "$(echo "$WW_FILES" | wc -l)" -ge 20 ]; then
        STATUS="${STATUS}\n(외 다수 존재...)"
    fi
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
| 대응방안 | 불필요한 World Writable 파일을 삭제하거나 권한(chmod o-w [FILE]) 변경 |

__MD_EOF__
