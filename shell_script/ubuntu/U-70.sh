#!/bin/bash
# shell_script/ubuntu/U-70.sh
# -----------------------------------------------------------------------------
# [U-70] 사용자 홈 디렉터리 권한 및 소유자 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 사용자 홈 디렉터리의 권한을 본인만 접근 가능하도록 제한하여 개인 데이터 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-70"
CATEGORY="계정 관리"
RISK="중"
ITEM="사용자 홈 디렉터리 권한 및 소유자 설정"

RESULT="양호"
STATUS=""
VULN_STATUS=""

# 1. 일반 사용자(UID 1000 이상) 홈 디렉터리 전수 조사
while IFS=: read -r USER_NAME _ UID_VAL _ _ HOME_DIR _; do
    if [ "$UID_VAL" -ge 1000 ] && [ "$USER_NAME" != "nobody" ]; then
        if [ -d "$HOME_DIR" ]; then
            OWNER=$(stat -c "%U" "$HOME_DIR")
            PERMS=$(stat -c "%a" "$HOME_DIR")
            
            # 소유자가 본인이 아니거나 타인이 읽기/쓰기 가능(700 초과)한 경우
            if [ "$OWNER" != "$USER_NAME" ] || [ "$PERMS" -gt 755 ]; then
                # 700이 권고이나 실무적 755까지 양호로 볼 수도 있음. 여기서는 엄격히 750 이상 체크
                if [ "$PERMS" -gt 750 ]; then
                    VULN_STATUS="${VULN_STATUS}${USER_NAME}(${PERMS}) "
                    RESULT="취약"
                fi
            fi
        fi
    fi
done < /etc/passwd

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 사용자의 홈 디렉터리 권한 및 소유 설정이 적절합니다."
else
    STATUS="다음 사용자들의 홈 디렉터리 권한이 부적절합니다: ${VULN_STATUS}"
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
| 대응방안 | 홈 디렉터리 권한을 700으로 변경하고 소유자를 해당 사용자로 설정 |

__MD_EOF__
