#!/bin/bash
# shell_script/centos/U-70.sh
# -----------------------------------------------------------------------------
# [U-70] 홈 디렉터리 내 환경 설정 파일 권한 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 환경 설정 파일(.bashrc 등)의 변조를 막아 악의적인 명령어 실행 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-70"
CATEGORY="계정 관리"
RISK="중"
ITEM="홈 디렉터리 내 환경 설정 파일 권한"

RESULT="양호"
STATUS=""
VULN_FILES=""

# 1. 점검 대상 환경 설정 파일 리스트
ENV_FILES=(".profile" ".bash_profile" ".bashrc" ".bash_history" ".cshrc" ".login")

# 2. 일반 사용자 홈 디렉터리 내 파일 점검
USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1":"$6}' /etc/passwd)

for USER_DATA in $USERS; do
    U_NAME=$(echo "$USER_DATA" | cut -d: -f1)
    U_HOME=$(echo "$USER_DATA" | cut -d: -f2)
    
    if [ -d "$U_HOME" ]; then
        for FILE_NAME in "${ENV_FILES[@]}"; do
            TARGET_FILE="${U_HOME}/${FILE_NAME}"
            if [ -f "$TARGET_FILE" ]; then
                OWNER=$(stat -c %U "$TARGET_FILE")
                PERM=$(stat -c %a "$TARGET_FILE")
                
                # 소유자가 root 또는 해당 사용자가 아니거나, 타인(Others)에게 쓰기 권한이 있는 경우
                if [[ "$OWNER" != "root" && "$OWNER" != "$U_NAME" ]] || [ "${PERM: -1}" -ge 2 ]; then
                    RESULT="취약"
                    VULN_FILES="${VULN_FILES}${TARGET_FILE}(소유:${OWNER},권한:${PERM}) "
                fi
            fi
        done
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 사용자 환경 설정 파일의 소유자 및 권한 설정이 적절합니다."
else
    STATUS="다음 환경 설정 파일들의 설정이 취약합니다: ${VULN_FILES}"
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
| 대응방안 | chown [계정] [파일] && chmod 644 [파일] |

__MD_EOF__
