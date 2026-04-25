#!/bin/bash
# shell_script/centos/U-21.sh
# -----------------------------------------------------------------------------
# [U-21] r 계열 서비스 비활성화 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 암호화되지 않은 r-command(rsh, rlogin, rexec) 서비스를 차단하여 가로채기 공격 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-21"
CATEGORY="서비스 관리"
RISK="상"
ITEM="r 계열 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. r-command 서비스 실행 여부 확인
R_SERVICES=("rsh" "rlogin" "rexec")
ACTIVE_R=""

for SVC in "${R_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SVC" 2>/dev/null || pgrep -x "${SVC}d" > /dev/null; then
        ACTIVE_R="${ACTIVE_R}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="r 계열 서비스가 모두 비활성화되어 있습니다. (SSH 사용 권고)"
else
    STATUS="취약한 r 계열 서비스(${ACTIVE_R})가 활성화되어 있습니다."
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
| 대응방안 | rsh, rlogin, rexec 등 r 계열 서비스 중지 및 SSH 전환 |

__MD_EOF__
