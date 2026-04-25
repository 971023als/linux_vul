#!/bin/bash
# shell_script/oracle/U-31.sh
# -----------------------------------------------------------------------------
# [U-31] 스팸 메일 릴레이 제한 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 외부의 악의적인 사용자가 시스템을 스팸 발송지로 악용하는 것을 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-31"
CATEGORY="서비스 관리"
RISK="상"
ITEM="스팸 메일 릴레이 제한"

RESULT="양호"
STATUS=""

if [ -f "/etc/mail/sendmail.cf" ]; then
    if grep -q "R$\*" "/etc/mail/sendmail.cf" | grep -q "Relaying denied"; then
        STATUS="Sendmail 릴레이 제한 설정이 활성화되어 있습니다."
    else
        if [ -f "/etc/mail/access" ] && grep -v "^#" "/etc/mail/access" | grep -q "RELAY"; then
            RESULT="취약"
            STATUS="Sendmail access 파일에 RELAY가 허용된 항목이 존재합니다."
        fi
    fi
fi

if [ -f "/etc/postfix/main.cf" ]; then
    MYNETWORKS=$(grep "^mynetworks =" "/etc/postfix/main.cf" | cut -d= -f2)
    if [[ "$MYNETWORKS" == *"0.0.0.0"* ]] || [ -z "$MYNETWORKS" ]; then
        if [[ "$MYNETWORKS" != *"127.0.0.1"* && -n "$MYNETWORKS" ]]; then
             RESULT="취약"
             STATUS="Postfix mynetworks 설정이 광범위하게 허용되어 있습니다: $MYNETWORKS"
        fi
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    [ -z "$STATUS" ] && STATUS="메일 서비스가 미사용 중이거나 릴레이 제한이 설정되어 있습니다."
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
| 대응방안 | SMTP 설정에서 릴레이를 제한하고 인가된 IP만 허용하도록 변경 |

__MD_EOF__
