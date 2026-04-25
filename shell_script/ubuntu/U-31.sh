#!/bin/bash
# shell_script/ubuntu/U-31.sh
# -----------------------------------------------------------------------------
# [U-31] 스팸 메일 릴레이 제한
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 메일 서버가 스팸 메일 발송의 경유지(Open Relay)로 악용되는 것을 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-31"
CATEGORY="서비스 관리"
RISK="상"
ITEM="스팸 메일 릴레이 제한"

RESULT="양호"
STATUS=""

# 1. Sendmail 릴레이 설정 확인
if [ -f "/etc/mail/sendmail.cf" ]; then
    if grep -qi "PromiscuousRelay" "/etc/mail/sendmail.cf"; then
        RESULT="취약"
        STATUS="Sendmail이 모든 릴레이를 허용(PromiscuousRelay)하도록 설정되어 있습니다."
    fi
fi

# 2. Postfix 릴레이 설정 확인
if [ -f "/etc/postfix/main.cf" ]; then
    # smtpd_recipient_restrictions 가 적절한지 확인 (permit_mynetworks, reject_unauth_destination 포함 여부)
    RELAY_RESTRICT=$(grep "^smtpd_recipient_restrictions" /etc/postfix/main.cf)
    if [ -n "$RELAY_RESTRICT" ] && [[ "$RELAY_RESTRICT" != *"reject_unauth_destination"* ]]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }Postfix 설정에 reject_unauth_destination 옵션이 누락되어 Open Relay 위험이 있습니다."
    fi
fi

if [ -z "$STATUS" ]; then
    STATUS="[양호] 메일 릴레이 제한 설정이 적절하거나 메일 서버를 사용하지 않습니다."
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
| 대응방안 | 1. Sendmail: access DB를 활용하여 특정 IP만 허용<br>2. Postfix: main.cf 에서 smtpd_recipient_restrictions 설정 강화 |

__MD_EOF__
