#!/bin/bash
# shell_script/ubuntu/U-64.sh
# -----------------------------------------------------------------------------
# [U-64] at 서비스 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 예약 작업 실행 권한 파일의 무단 수정을 방지하여 악성 작업 등록 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-64"
CATEGORY="서비스 관리"
RISK="하"
ITEM="at 서비스 권한 설정"

RESULT="양호"
STATUS=""

# 1. 점검 대상 파일
AT_FILES=("/etc/at.allow" "/etc/at.deny")
VULN_STATUS=""

for FILE in "${AT_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE")
        PERMS=$(stat -c "%a" "$FILE")
        
        if [ "$OWNER" != "root" ] || [ "$PERMS" -gt 640 ]; then
            VULN_STATUS="${VULN_STATUS}${FILE}(${OWNER}, ${PERMS}) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] at 관련 설정 파일의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="[취약] 다음 파일들의 설정이 부적절합니다: ${VULN_STATUS}"
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
| 대응방안 | at.allow, at.deny 파일의 소유자를 root로 변경하고 권한을 640 이하로 설정 |

__MD_EOF__
