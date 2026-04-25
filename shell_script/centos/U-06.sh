#!/bin/bash
# shell_script/centos/U-06.sh
# -----------------------------------------------------------------------------
# [U-06] 파일 및 디렉터리 소유자 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 소유자가 존재하지 않는 파일을 찾아 무단 사용 또는 권한 오용 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-06"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="파일 및 디렉터리 소유자 설정"

RESULT="양호"
STATUS=""

# 1. 소유자 또는 그룹이 없는 파일 검색
# 가상 파일시스템 제외
NO_OWNER_FILES=$(find / \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o \( -nouser -o -nogroup \) -print 2>/dev/null | head -n 20)

if [ -z "$NO_OWNER_FILES" ]; then
    STATUS="소유자나 그룹이 없는 파일이 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="소유자나 그룹이 없는 파일이 존재합니다:\n$NO_OWNER_FILES"
    if [ "$(echo "$NO_OWNER_FILES" | wc -l)" -ge 20 ]; then
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
| 대응방안 | 소유자가 없는 파일의 소유자를 적절한 계정(root 등)으로 변경하거나 삭제 |

__MD_EOF__
