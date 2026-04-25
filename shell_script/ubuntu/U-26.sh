#!/bin/bash
# shell_script/ubuntu/U-26.sh
# -----------------------------------------------------------------------------
# [U-26] automountd 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 자동 마운트 서비스를 차단하여 인가되지 않은 이동식 매체 접근 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-26"
CATEGORY="서비스 관리"
RISK="상"
ITEM="automountd 비활성화"

RESULT="양호"
STATUS=""

# 1. autofs 서비스 실행 여부 확인 (Ubuntu/Debian)
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet autofs 2>/dev/null; then
        RESULT="취약"
        STATUS="autofs(automountd) 서비스가 현재 실행 중입니다."
    fi
fi

# 2. 프로세스 확인 (automount)
if pgrep -x "automount" >/dev/null 2>&1; then
    RESULT="취약"
    STATUS="${STATUS:+$STATUS / }automount 프로세스가 동작 중입니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] automountd 서비스가 비활성화되어 있습니다."
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
| 대응방안 | automountd(autofs) 서비스 중지 및 비활성화 (systemctl stop/disable autofs) |

__MD_EOF__
