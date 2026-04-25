#!/bin/bash
# shell_script/oracle/U-14.sh
# -----------------------------------------------------------------------------
# [U-14] 사용자, 시스템별 외환경 변수 파일 권한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 환경 설정 파일의 무단 수정을 방지하여 사용자 환경 변조 및 악성 코드 삽입 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-14"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="사용자, 시스템별 외환경 변수 파일 권한 설정"

RESULT="양호"
STATUS=""

TARGET_FILES=("/etc/profile" "/etc/bashrc" "/etc/csh.login" "/etc/csh.cshrc")
VULN_STATUS=""

for FILE in "${TARGET_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE")
        PERMS=$(stat -c "%a" "$FILE")
        
        if [ "$OWNER" != "root" ] || [ "$PERMS" -gt 644 ]; then
            VULN_STATUS="${VULN_STATUS}${FILE}(${OWNER}, ${PERMS}) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="주요 환경 설정 파일의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="다음 파일들의 소유자 또는 권한 설정이 부적절합니다: ${VULN_STATUS}"
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
| 대응방안 | 환경 설정 파일의 소유자를 root로 변경하고 권한을 644 이하로 설정 |

__MD_EOF__
