#!/bin/bash
# shell_script/oracle/U-38.sh
# -----------------------------------------------------------------------------
# [U-38] 웹 서비스 불필요한 파일 제거 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 기본으로 제공되는 가이드 파일 및 샘플 파일을 제거하여 시스템 정보 노출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-38"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹 서비스 불필요한 파일 제거"

RESULT="양호"
STATUS=""

VULN_STATUS=""
CHECK_DIRS=("/var/www/manual" "/var/www/html/manual" "/var/www/error" "/usr/share/doc/httpd")

for DIR in "${CHECK_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        VULN_STATUS="${VULN_STATUS}${DIR} "
        RESULT="취약"
    fi
done

if [ -f "/etc/httpd/conf.d/manual.conf" ]; then
    RESULT="취약"
    VULN_STATUS="${VULN_STATUS}/etc/httpd/conf.d/manual.conf "
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="웹 서비스 기본 매뉴얼 및 불필요한 파일이 존재하지 않습니다."
else
    STATUS="웹 서비스 기본 파일 또는 매뉴얼 설정이 존재합니다: ${VULN_STATUS}"
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
| 대응방안 | 웹 서버 설치 시 기본으로 생성되는 manual, 샘플 파일 및 설정 삭제 |

__MD_EOF__
