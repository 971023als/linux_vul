#!/bin/bash
# shell_script/oracle/U-51.sh
# -----------------------------------------------------------------------------
# [U-51] 계정 UID 중복 점검 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.5.1(사용자 식별)
# - 목적: 동일한 UID를 가진 중복 계정을 식별하여 권한 부여 오류 및 감사 무결성 훼손 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-51"
CATEGORY="계정 관리"
RISK="중"
ITEM="계정 UID 중복 점검"

RESULT="양호"
STATUS=""

DUPLICATE_UIDS=$(cut -d: -f3 /etc/passwd | sort | uniq -d)

if [ -n "$DUPLICATE_UIDS" ]; then
    RESULT="취약"
    VULN_ACCOUNTS=""
    for UID_VAL in $DUPLICATE_UIDS; do
        ACCOUNTS=$(grep ":$UID_VAL:" /etc/passwd | cut -d: -f1 | xargs)
        VULN_ACCOUNTS="${VULN_ACCOUNTS}UID(${UID_VAL}):[${ACCOUNTS}] "
    done
    STATUS="중복된 UID를 사용하는 계정이 존재합니다: ${VULN_ACCOUNTS}"
else
    STATUS="중복된 UID를 사용하는 계정이 존재하지 않습니다."
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
| 대응방안 | 중복된 UID를 가진 계정의 UID를 고유한 값으로 변경 |

__MD_EOF__
