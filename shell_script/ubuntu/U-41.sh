#!/bin/bash
# shell_script/ubuntu/U-41.sh
# -----------------------------------------------------------------------------
# [U-41] 웹서비스 영역의 분리
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 웹 서버의 데이터 영역과 시스템 영역을 분리하여 로그 폭주 시 시스템 마비 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-41"
CATEGORY="서비스 관리"
RISK="상"
ITEM="웹서비스 영역의 분리"

RESULT="양호"
STATUS=""

# 1. 웹 루트 디렉토리가 별도 파티션인지 확인
WEB_ROOT="/var/www"
if [ -d "$WEB_ROOT" ]; then
    ROOT_DEV=$(df "$WEB_ROOT" | tail -1 | awk '{print $1}')
    SYS_ROOT_DEV=$(df "/" | tail -1 | awk '{print $1}')
    
    if [ "$ROOT_DEV" == "$SYS_ROOT_DEV" ]; then
        RESULT="취약"
        STATUS="웹 루트 디렉토리($WEB_ROOT)가 루트(/) 파티션과 분리되어 있지 않습니다."
    else
        STATUS="웹 루트 디렉토리가 별도 파티션($ROOT_DEV)으로 분리되어 있습니다."
    fi
else
    STATUS="웹 서비스 디렉토리가 존재하지 않습니다(해당없음)."
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
| 대응방안 | 웹 서버 데이터 영역(/var/www 등)을 별도의 파티션으로 구성 |

__MD_EOF__
