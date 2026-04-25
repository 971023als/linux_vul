#!/bin/bash
# shell_script/ubuntu/U-13.sh
# -----------------------------------------------------------------------------
# [U-13] SUID, SGID 설정 및 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 SUID/SGID 설정을 제거하여 일반 사용자의 권한 상승 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-13"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="SUID, SGID 설정 및 권한 설정"

RESULT="양호"
STATUS=""

# 주요 점검 대상 파일 리스트 (보통 SUID가 없어야 하거나 주의가 필요한 것들)
CHECK_LIST=(
    "/sbin/unix_chkpwd" "/usr/bin/at" "/usr/bin/lpq" "/usr/bin/lprm"
    "/usr/bin/newgrp" "/usr/sbin/lpc" "/usr/sbin/lpd"
)

VULN_FILES=""

for FILE in "${CHECK_LIST[@]}"; do
    if [ -f "$FILE" ]; then
        # SUID(4000) 또는 SGID(2000) 설정 확인
        if [ -u "$FILE" ] || [ -g "$FILE" ]; then
            VULN_FILES="${VULN_FILES}${FILE}\n"
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 주요 바이너리에 불필요한 SUID/SGID 설정이 없습니다."
else
    STATUS="[취약] 다음 파일들에 불필요한 SUID/SGID 설정이 존재합니다:\n${VULN_FILES}"
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
| 대응방안 | 불필요한 SUID/SGID 파일 권한 제거 (chmod -s [FILE]) |

__MD_EOF__
