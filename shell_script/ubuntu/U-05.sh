#!/bin/bash
# shell_script/ubuntu/U-05.sh
# -----------------------------------------------------------------------------
# [U-05] root홈, 패스 디렉터리 권한 및 패스 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: PATH 환경 변수에 현재 디렉터리('.')가 포함되어 발생할 수 있는 악성 스크립트 실행 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-05"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="root홈, 패스 디렉터리 권한 및 패스 설정"

RESULT="양호"
STATUS=""

# 1. PATH 환경 변수 점검 ('.' 또는 '::' 포함 여부)
# 현재 쉘의 PATH와 주요 설정 파일 검사
CHECK_FILES=("/etc/profile" "/etc/bash.bashrc" "/root/.bashrc" "/root/.profile")

# 현재 쉘 PATH 확인
if echo "$PATH" | grep -Eq "\.\/|::|:\.$|^\.:"; then
    RESULT="취약"
    STATUS="현재 쉘의 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다."
fi

# 설정 파일 내 PATH 설정 확인
for FILE in "${CHECK_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        if grep -q "PATH=" "$FILE" | grep -Eq "\.\/|::|:\.$|^\.:"; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }$FILE 내 PATH 설정에 위험한 경로가 포함되어 있습니다."
        fi
    fi
done

# 2. root 홈 디렉터리 권한 점검
ROOT_HOME=$(grep "^root:" /etc/passwd | cut -d: -f6)
if [ -d "$ROOT_HOME" ]; then
    PERMS=$(stat -c "%a" "$ROOT_HOME")
    # root 홈은 보통 700 또는 750이어야 함 (Group/Other Write 권한 금지)
    if [ "${PERMS:1:1}" -gt 5 ] || [ "${PERMS:2:1}" -gt 5 ]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }root 홈 디렉터리($ROOT_HOME)의 권한이 취약합니다($PERMS)."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] PATH 환경 변수 및 root 홈 디렉터리 권한 설정이 적절합니다."
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
| 대응방안 | 1. PATH 환경 변수에서 '.' 또는 '::' 제거<br>2. root 홈 디렉터리 권한을 700으로 변경 (chmod 700 /root) |

__MD_EOF__
