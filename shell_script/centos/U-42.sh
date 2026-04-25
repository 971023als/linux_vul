#!/bin/bash
# shell_script/centos/U-42.sh
# -----------------------------------------------------------------------------
# [U-42] 최신 보안 패치 및 업데이트 점검 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.2(취약점 관리)
# - 목적: 최신 보안 패치를 적용하여 알려진 취약점을 통한 시스템 침해 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-42"
CATEGORY="서비스 관리"
RISK="상"
ITEM="최신 보안 패치 및 업데이트 점검"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 보안 업데이트 확인 (yum 또는 dnf)
if command -v dnf > /dev/null; then
    SEC_UPDATES=$(dnf updateinfo list security --installed 2>/dev/null | grep "Security" | wc -l)
    PENDING_SEC=$(dnf updateinfo list security 2>/dev/null | grep "Security" | wc -l)
    if [ "$PENDING_SEC" -gt 0 ]; then
        RESULT="취약"
        STATUS="미적용된 보안 업데이트가 ${PENDING_SEC}건 존재합니다."
    else
        STATUS="모든 보안 업데이트가 적용되어 있습니다."
    fi
elif command -v yum > /dev/null; then
    # yum-plugin-security 가 설치되어 있어야 정확함
    PENDING_SEC=$(yum check-update --security 2>/dev/null | grep -i "security" | wc -l)
    if [ "$PENDING_SEC" -gt 0 ]; then
        RESULT="취약"
        STATUS="미적용된 보안 업데이트가 존재합니다(yum check-update --security 확인 필요)."
    else
        STATUS="보안 업데이트가 최신 상태이거나 추가 확인이 필요합니다."
    fi
else
    STATUS="패키지 매니저(dnf/yum)를 확인할 수 없습니다."
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
| 대응방안 | dnf update --security 또는 yum update --security 실행 |

__MD_EOF__
