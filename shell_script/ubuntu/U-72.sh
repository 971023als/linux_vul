#!/bin/bash
# shell_script/ubuntu/U-72.sh
# -----------------------------------------------------------------------------
# [U-72] 정책에 따른 시스템 로그 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 주요 시스템 로그(인증, 작업 등)를 충실히 기록하여 사고 대응 및 감사 체계 구축
# -----------------------------------------------------------------------------

set -u

CODE="U-72"
CATEGORY="로그 관리"
RISK="하"
ITEM="정책에 따른 시스템 로그 설정"

RESULT="양호"
STATUS=""

# 1. rsyslog 설정 파일 점검
CONF_FILES=("/etc/rsyslog.conf")
[ -d "/etc/rsyslog.d" ] && CONF_FILES+=($(find /etc/rsyslog.d -name "*.conf"))

REQUIRED_LOGS=("auth" "authpriv" "cron" "daemon" "kern" "mail" "syslog")
MISSING_LOGS=""

# 모든 파일에서 필수 로그 항목이 하나라도 설정되어 있는지 확인
for LOG in "${REQUIRED_LOGS[@]}"; do
    FOUND_IN_FILES=false
    for FILE in "${CONF_FILES[@]}"; do
        if grep -qE "^$LOG\." "$FILE" 2>/dev/null; then
            FOUND_IN_FILES=true
            break
        fi
    done
    if ! $FOUND_IN_FILES; then
        MISSING_LOGS="${MISSING_LOGS}${LOG} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="주요 로그 항목이 rsyslog 설정에 모두 포함되어 있습니다."
else
    STATUS="다음 주요 로그 항목의 설정이 누락되어 있습니다: ${MISSING_LOGS}"
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
| 대응방안 | /etc/rsyslog.conf 에 누락된 로그 기록 설정(예: authpriv.* /var/log/auth.log) 추가 |

__MD_EOF__
