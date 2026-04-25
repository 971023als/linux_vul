#!/bin/bash
# shell_script/oracle/U-04.sh
# -----------------------------------------------------------------------------
# [U-04] 패스워드 파일 보호 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 패스워드를 shadow 파일에 별도 저장하여 일반 사용자의 접근 및 크래킹 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-04"
CATEGORY="계정 관리"
RISK="상"
ITEM="패스워드 파일 보호"

RESULT="양호"
STATUS=""

if [ -f "/etc/passwd" ]; then
    VULN_ACCOUNTS=$(awk -F: '$2 != "x" {print $1}' /etc/passwd)
    if [ -n "$VULN_ACCOUNTS" ]; then
        RESULT="취약"
        STATUS="패스워드가 shadow 파일에 저장되지 않은 계정 발견: ${VULN_ACCOUNTS}"
    else
        STATUS="모든 계정의 패스워드가 shadow 파일에 보호되고 있습니다."
    fi
else
    RESULT="취약"
    STATUS="/etc/passwd 파일을 찾을 수 없습니다."
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
| 대응방안 | pwconv 명령을 사용하여 shadow 패스워드 체계로 변환 |

__MD_EOF__
