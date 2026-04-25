#!/bin/bash
# shell_script/centos/U-64.sh
# -----------------------------------------------------------------------------
# [U-64] at 파일 권한 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 일반 사용자의 at 명령어 사용을 제한하여 악의적인 예약 작업 실행 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-64"
CATEGORY="서비스 관리"
RISK="하"
ITEM="at 파일 권한 설정"

RESULT="양호"
STATUS=""
CHECK_FILES=("/etc/at.allow" "/etc/at.deny")
VULN_STATUS=""

for FILE in "${CHECK_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c %U "$FILE")
        PERM=$(stat -c %a "$FILE")
        
        # 소유자 root 및 권한 640 이하 확인
        if [ "$OWNER" != "root" ] || [ "$PERM" -gt 640 ]; then
            RESULT="취약"
            VULN_STATUS="${VULN_STATUS}${FILE}(소유:${OWNER},권한:${PERM}) "
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="at 관련 설정 파일의 소유자 및 권한이 적절합니다."
else
    STATUS="at 관련 파일의 권한 설정이 부적절합니다: ${VULN_STATUS}"
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
| 대응방안 | chown root [파일] && chmod 640 [파일] |

__MD_EOF__
