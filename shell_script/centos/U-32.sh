#!/bin/bash
# shell_script/centos/U-32.sh
# -----------------------------------------------------------------------------
# [U-32] 일반 사용자의 Sendmail 실행 방지 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 일반 사용자가 메일 큐를 조작하거나 불필요한 데몬 정보를 획득하는 것을 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-32"
CATEGORY="서비스 관리"
RISK="하"
ITEM="일반 사용자의 Sendmail 실행 방지"

RESULT="양호"
STATUS=""
TARGET="/etc/mail/sendmail.cf"

# 1. Sendmail 설정 파일 존재 여부 확인
if [ -f "$TARGET" ]; then
    # PrivacyOptions 설정 내 restrictqrun 옵션 확인
    if grep -i "PrivacyOptions" "$TARGET" | grep -qi "restrictqrun"; then
        STATUS="Sendmail 일반 사용자 실행 제한(restrictqrun)이 설정되어 있습니다."
    else
        RESULT="취약"
        STATUS="Sendmail 설정에 restrictqrun 옵션이 누락되었습니다."
    fi
else
    STATUS="Sendmail 설정 파일($TARGET)이 존재하지 않습니다(해당없음)."
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
| 대응방안 | sendmail.cf 파일의 PrivacyOptions 에 restrictqrun 옵션 추가 |

__MD_EOF__
