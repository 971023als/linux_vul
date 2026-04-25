#!/bin/bash
# shell_script/ubuntu/U-54.sh
# -----------------------------------------------------------------------------
# [U-54] Session Timeout 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제11조(권한 부여), ISMS-P 2.5.1(사용자 식별)
# - 목적: 일정 시간 사용하지 않는 세션을 자동으로 종료하여 물리적 무단 사용 및 세션 하이재킹 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-54"
CATEGORY="계정 관리"
RISK="하"
ITEM="Session Timeout 설정"

RESULT="양호"
STATUS=""

# 1. TMOUT 설정 확인 (공통 설정 파일 탐색)
CHECK_FILES=("/etc/profile" "/etc/bash.bashrc" "/etc/profile.d/*.sh")
TMOUT_VAL=""

# 실제 로드된 환경변수 확인 (현재 세션 기반은 한계가 있으므로 파일 직접 파싱)
for FILE in $CHECK_FILES; do
    if [ -f "$FILE" ]; then
        VAL=$(grep -E "TMOUT=" "$FILE" | grep -v "^#" | tail -1 | cut -d= -f2)
        if [ -n "$VAL" ]; then
            TMOUT_VAL=$VAL
            break
        fi
    fi
done

if [ -z "$TMOUT_VAL" ]; then
    RESULT="취약"
    STATUS="세션 타임아웃(TMOUT) 설정이 존재하지 않습니다."
else
    # 600초(10분) 이하 권고
    if [ "$TMOUT_VAL" -le 600 ]; then
        STATUS="TMOUT이 ${TMOUT_VAL}초로 적절히 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="TMOUT이 권고치(600초)보다 큰 ${TMOUT_VAL}초로 설정되어 있습니다."
    fi
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
| 대응방안 | /etc/profile 에 TMOUT=600 및 export TMOUT 추가 |

__MD_EOF__
