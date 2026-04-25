#!/bin/bash
# shell_script/ubuntu/U-38.sh
# -----------------------------------------------------------------------------
# [U-38] 웹서비스 불필요한 파일 제거
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 서버 설치 시 기본으로 생성되는 샘플 파일, 매뉴얼 등을 제거하여 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-38"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 불필요한 파일 제거"

RESULT="양호"
STATUS=""

# 1. 점검 대상 디렉토리 및 파일 (Apache/Nginx 기본 경로)
WEB_ROOTS=("/var/www/html" "/usr/share/apache2/default-site" "/var/www/manual")
DEFAULT_FILES=("index.html.gz" "manual" "sample" "test.cgi" "phpinfo.php")

VULN_ITEMS=""

for ROOT in "${WEB_ROOTS[@]}"; do
    if [ -d "$ROOT" ]; then
        for FILE in "${DEFAULT_FILES[@]}"; do
            if [ -e "$ROOT/$FILE" ]; then
                VULN_ITEMS="${VULN_ITEMS}$ROOT/$FILE\n"
                RESULT="취약"
            fi
        done
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 웹 서비스 기본 파일 및 매뉴얼이 존재하지 않습니다."
else
    STATUS="[취약] 다음 불필요한 파일/디렉토리가 존재합니다:\n${VULN_ITEMS}"
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
| 대응방안 | 웹 서버 루트 디렉토리 내 불필요한 기본 파일 및 매뉴얼 삭제 |

__MD_EOF__
