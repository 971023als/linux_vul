#!/bin/bash
# shell_script/ubuntu/U-42.sh
# -----------------------------------------------------------------------------
# [U-42] 최신 패치 적용
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.2(패치 관리)
# - 목적: 알려진 취약점에 대한 보안 패치를 적용하여 시스템 침해 사고 예방
# -----------------------------------------------------------------------------

set -u

CODE="U-42"
CATEGORY="패치 관리"
RISK="상"
ITEM="최신 패치 적용"

RESULT="양호"
STATUS=""

# 1. 보안 업데이트 대상 확인 (Ubuntu)
if command -v apt >/dev/null 2>&1; then
    # 업데이트 목록 갱신 시뮬레이션 및 보안 관련 패키지만 카운트
    SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i "security" | wc -l)
    
    if [ "$SEC_UPDATES" -gt 0 ]; then
        RESULT="취약"
        STATUS="현재 적용 가능한 보안 업데이트가 ${SEC_UPDATES}건 존재합니다."
    else
        STATUS="모든 보안 패치가 최신 상태입니다."
    fi
else
    STATUS="패키지 관리자(apt)를 사용할 수 없습니다."
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
| 대응방안 | 보안 업데이트 적용 (apt update && apt upgrade) |

__MD_EOF__
