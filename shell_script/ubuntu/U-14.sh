#!/bin/bash
# shell_script/ubuntu/U-14.sh
# -----------------------------------------------------------------------------
# [U-14] 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 환경 설정 파일의 무단 수정을 방지하여 악성 스크립트 삽입 및 환경 변수 조작 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-14"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""

# 1. 시스템 시작 파일 점검
SYS_FILES=("/etc/profile" "/etc/bash.bashrc" "/etc/environment")
VULN_FILES=""

for FILE in "${SYS_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE")
        PERMS=$(stat -c "%a" "$FILE")
        # 소유자가 root가 아니거나 쓰기 권한이 타인에게 있는 경우
        if [ "$OWNER" != "root" ] || [ "${PERMS:1:1}" -gt 4 ] || [ "${PERMS:2:1}" -gt 4 ]; then
            VULN_FILES="${VULN_FILES}${FILE} (Owner: $OWNER, Perm: $PERMS)\n"
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 시스템 환경 설정 파일의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="[취약] 다음 파일들의 권한 설정이 부적절합니다:\n${VULN_FILES}"
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
| 대응방안 | 소유자를 root로 변경하고 타인의 쓰기 권한 제거 (chmod 644 [FILE]) |

__MD_EOF__
