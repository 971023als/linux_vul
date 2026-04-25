#!/bin/bash
# shell_script/oracle/U-08.sh
# -----------------------------------------------------------------------------
# [U-08] /etc/shadow 파일 소유자 및 권한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 암호화된 패스워드 저장 파일의 접근을 원천 차단하여 패스워드 탈취 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-08"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/shadow 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/shadow"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c "%U" "$TARGET")
    PERMS=$(stat -c "%a" "$TARGET")
    
    if [ "$OWNER" != "root" ]; then
        RESULT="취약"
        STATUS="소유자가 root가 아닌 $OWNER 입니다."
    fi
    
    if [ "$PERMS" -gt 600 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }권한이 600보다 큰 $PERMS 입니다."
    fi
else
    RESULT="취약"
    STATUS="$TARGET 파일을 찾을 수 없습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $TARGET 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root ${TARGET} && chmod 400 ${TARGET} |

__MD_EOF__
