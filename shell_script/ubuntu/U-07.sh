#!/bin/bash
# shell_script/ubuntu/U-07.sh
# -----------------------------------------------------------------------------
# [U-07] /etc/passwd 파일 소유자 및 권한 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 사용자 계정 정보가 포함된 파일의 무단 수정을 방지하여 계정 변조 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-07"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/passwd 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/passwd"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c "%U" "$TARGET")
    PERMS=$(stat -c "%a" "$TARGET")
    
    # 소유자가 root가 아니거나, 권한이 644보다 큰 경우 (Write 권한이 타인에게 있는 경우)
    if [ "$OWNER" != "root" ]; then
        RESULT="취약"
        STATUS="소유자가 root가 아닌 $OWNER 입니다."
    fi
    
    # 644(rw-r--r--) 이하인지 체크
    if [ "$PERMS" -gt 644 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }권한이 644보다 큰 $PERMS 입니다."
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
| 대응방안 | chown root ${TARGET} && chmod 644 ${TARGET} |

__MD_EOF__
