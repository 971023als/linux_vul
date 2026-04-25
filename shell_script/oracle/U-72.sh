#!/bin/bash
# shell_script/oracle/U-72.sh
# -----------------------------------------------------------------------------
# [U-72] 로그 기록의 정기적 검토 및 보고 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 주요 시스템 로그가 적절히 기록되도록 설정하여 보안 사고 발생 시 증거 확보
# -----------------------------------------------------------------------------

set -u

CODE="U-72"
CATEGORY="로그 관리"
RISK="상"
ITEM="로그 기록의 정기적 검토 및 보고"

RESULT="양호"
STATUS=""
TARGET="/etc/rsyslog.conf"

if [ -f "$TARGET" ]; then
    CHECK_FLAGS=0
    
    if grep -v "^#" "$TARGET" | grep -q "authpriv"; then
        CHECK_FLAGS=$((CHECK_FLAGS + 1))
    fi
    if grep -v "^#" "$TARGET" | grep -q "kern"; then
        CHECK_FLAGS=$((CHECK_FLAGS + 1))
    fi
    if grep -v "^#" "$TARGET" | grep -q "mail"; then
        CHECK_FLAGS=$((CHECK_FLAGS + 1))
    fi
    if grep -v "^#" "$TARGET" | grep -q "cron"; then
        CHECK_FLAGS=$((CHECK_FLAGS + 1))
    fi

    if [ "$CHECK_FLAGS" -ge 4 ]; then
        STATUS="주요 시스템 로그(auth, kern, mail, cron)가 적절히 기록되도록 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="주요 로그 중 일부가 rsyslog 설정에서 누락되었습니다 (탐지된 로그 수: ${CHECK_FLAGS}/4)."
    fi
else
    RESULT="취약"
    STATUS="rsyslog 설정 파일($TARGET)이 존재하지 않습니다."
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
| 대응방안 | rsyslog.conf 파일에 주요 로그 항목(authpriv.*, kern.* 등) 추가 |

__MD_EOF__
