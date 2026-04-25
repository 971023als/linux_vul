#!/bin/bash
# shell_script/ubuntu/U-16.sh
# -----------------------------------------------------------------------------
# [U-16] /dev에 존재하지 않는 device 파일 점검
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: /dev 디렉터리에 일반 파일을 생성하여 데이터를 은닉하는 행위 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-16"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/dev에 존재하지 않는 device 파일 점검"

RESULT="양호"
STATUS=""

# 1. /dev 내의 일반 파일(f) 검색 (블록/캐릭터 디바이스가 아닌 파일)
INVALID_DEV_FILES=$(find /dev -type f 2>/dev/null)

if [ -z "$INVALID_DEV_FILES" ]; then
    STATUS="/dev 디렉터리에 비정상적인 일반 파일이 존재하지 않습니다."
else
    RESULT="취약"
    STATUS="/dev 디렉터리에 일반 파일이 존재합니다:\n${INVALID_DEV_FILES}"
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
| 대응방안 | /dev 디렉터리 내의 불필요한 일반 파일 삭제 |

__MD_EOF__
