#!/bin/bash
# shell_script/ubuntu/U-28.sh
# -----------------------------------------------------------------------------
# [U-28] NIS, NIS+ 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 보안에 취약한 NIS 서비스를 차단하여 계정 정보 등 민감 데이터 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-28"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NIS, NIS+ 비활성화"

RESULT="양호"
STATUS=""

# 1. NIS 관련 서비스 점검 (Ubuntu/Debian)
NIS_SERVICES=("ypserv" "ypbind" "yppasswdd" "ypxfrd")

if command -v systemctl >/dev/null 2>&1; then
    for SVC in "${NIS_SERVICES[@]}"; do
        if systemctl is-active --quiet "$SVC" 2>/dev/null; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }${SVC} 서비스가 활성화되어 있습니다."
        fi
    done
fi

# 2. 프로세스 확인
if pgrep -x "ypserv" >/dev/null 2>&1 || pgrep -x "ypbind" >/dev/null 2>&1; then
    RESULT="취약"
    STATUS="${STATUS:+$STATUS / }NIS 관련 프로세스가 동작 중입니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] NIS, NIS+ 서비스가 비활성화되어 있습니다."
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
| 대응방안 | NIS 관련 서비스 중지 및 패키지 삭제 (apt remove nis) |

__MD_EOF__
