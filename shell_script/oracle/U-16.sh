#!/bin/bash
# shell_script/oracle/U-16.sh
# -----------------------------------------------------------------------------
# [U-16] /dev 내 존재하지 않는 device 파일 점검 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: /dev 디렉터리 내에 일반 파일을 생성하여 데이터를 은닉하는 백도어 행위 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-16"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/dev 내 존재하지 않는 device 파일 점검"

RESULT="양호"
STATUS=""

VULN_FILES=$(find /dev -type f -print 2>/dev/null)

if [ -z "$VULN_FILES" ]; then
    STATUS="/dev 디렉터리에 부적절한 일반 파일이 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="/dev 내에 일반 파일이 발견되었습니다: ${VULN_FILES}"
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
| 대응방안 | /dev 내의 일반 파일 확인 후 불필요한 경우 삭제 |

__MD_EOF__
