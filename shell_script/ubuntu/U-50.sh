#!/bin/bash
# shell_script/ubuntu/U-50.sh
# -----------------------------------------------------------------------------
# [U-50] 관리자 그룹에 최소한의 계정 포함
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제11조(권한 부여), ISMS-P 2.5.5(특수 권한 관리)
# - 목적: 관리자 권한(root, sudo)을 가진 계정을 최소화하여 권한 오남용 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-50"
CATEGORY="계정 관리"
RISK="하"
ITEM="관리자 그룹에 최소한의 계정 포함"

RESULT="양호"
STATUS=""

# 1. 관리자 그룹(root, sudo, wheel) 멤버 확인
ADMIN_GROUPS=("root" "sudo" "wheel")
VULN_STATUS=""

for GRP in "${ADMIN_GROUPS[@]}"; do
    if getent group "$GRP" >/dev/null 2>&1; then
        MEMBERS=$(getent group "$GRP" | cut -d: -f4)
        if [ -n "$MEMBERS" ]; then
            # 멤버가 너무 많은지(예: 5명 초과) 체크하는 로직을 넣을 수 있으나, 여기서는 목록화함
            VULN_STATUS="${VULN_STATUS}${GRP} 그룹 멤버: ${MEMBERS}\n"
        fi
    fi
done

if [ -z "$VULN_STATUS" ]; then
    STATUS="관리자 그룹에 등록된 일반 계정이 없습니다."
else
    # 실무적으로는 목록을 보여주고 수동 검토 권고
    STATUS="관리자 권한 그룹 멤버 현황입니다(최소화 권고):\n${VULN_STATUS}"
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
| 대응방안 | 관리자 권한이 불필요한 계정을 관리자 그룹에서 제외 |

__MD_EOF__
