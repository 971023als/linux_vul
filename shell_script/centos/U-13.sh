#!/bin/bash
# shell_script/centos/U-13.sh
# -----------------------------------------------------------------------------
# [U-13] SUID, SGID, 설정 파일 점검 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.5(특수 권한 관리)
# - 목적: 불필요한 특수 권한(SUID/SGID)이 설정된 파일을 제거하여 권한 상승 공격 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-13"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="SUID, SGID, 설정 파일 점검"

RESULT="양호"
STATUS=""

# 1. 점검 대상 SUID/SGID 파일 목록 (RHEL 계열 권고 대상)
CHECK_LIST=(
    "/sbin/dump" "/sbin/restore" "/sbin/unix_chkpwd"
    "/usr/bin/at" "/usr/bin/lpq" "/usr/bin/lpr" "/usr/bin/lprm" "/usr/bin/newgrp"
    "/usr/sbin/lpc" "/usr/sbin/lpd"
)

VULN_FILES=""

for FILE in "${CHECK_LIST[@]}"; do
    if [ -f "$FILE" ]; then
        # SUID(4000) 또는 SGID(2000) 비트 확인
        if [ -u "$FILE" ] || [ -g "$FILE" ]; then
            VULN_FILES="${VULN_FILES}${FILE} "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="주요 파일들에 불필요한 SUID/SGID 설정이 없습니다."
else
    STATUS="다음 파일들에 SUID/SGID 설정이 존재합니다: ${VULN_FILES}"
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
| 대응방안 | 불필요한 경우 chmod -s [FILE] 명령으로 SUID/SGID 제거 |

__MD_EOF__
