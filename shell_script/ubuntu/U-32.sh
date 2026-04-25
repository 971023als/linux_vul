#!/bin/bash
# shell_script/ubuntu/U-32.sh
# -----------------------------------------------------------------------------
# [U-32] 일반사용자의 Sendmail 실행 방지
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 일반 사용자가 메일 큐를 조작하거나 Sendmail의 취약점을 이용하여 권한을 획득하는 행위 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-32"
CATEGORY="서비스 관리"
RISK="상"
ITEM="일반사용자의 Sendmail 실행 방지"

RESULT="양호"
STATUS=""

# 1. Sendmail 설정 파일 내 PrivacyOptions 점검
if [ -f "/etc/mail/sendmail.cf" ]; then
    if ! grep -qi "PrivacyOptions" "/etc/mail/sendmail.cf" | grep -qi "restrictqrun"; then
        RESULT="취약"
        STATUS="Sendmail 설정에 restrictqrun 옵션이 누락되어 일반 사용자가 큐를 실행할 수 있습니다."
    fi
else
    # Postfix는 기본적으로 큐 접근이 제한되어 있음
    STATUS="Sendmail 서비스가 설치되어 있지 않거나 설정 파일이 없습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] $STATUS"
    [[ "$STATUS" == *"(해당없음)"* ]] || STATUS="[양호] 일반사용자의 Sendmail 큐 실행이 제한되어 있습니다."
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
| 대응방안 | sendmail.cf 파일의 PrivacyOptions 에 restrictqrun 추가 |

__MD_EOF__
