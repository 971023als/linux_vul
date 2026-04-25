#!/bin/bash
# shell_script/oracle/U-57.sh
# -----------------------------------------------------------------------------
# [U-57] NFS root 제한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 원격 root 권한 획득을 방지하기 위해 NFS 공유 시 root 권한 매핑 제한
# -----------------------------------------------------------------------------

set -u

CODE="U-57"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS root 제한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/exports"

if [ -f "$TARGET" ]; then
    if grep -v "^#" "$TARGET" | grep -q "no_root_squash"; then
        RESULT="취약"
        VULN_SHARES=$(grep -v "^#" "$TARGET" | grep "no_root_squash" | awk '{print $1}' | xargs)
        STATUS="NFS 공유 중 root 권한 제한(root_squash)이 설정되지 않은 경로가 존재합니다: ${VULN_SHARES}"
    else
        STATUS="NFS 모든 공유 항목에 root_squash 또는 적절한 제한이 설정되어 있습니다."
    fi
else
    STATUS="/etc/exports 파일이 존재하지 않습니다(해당없음)."
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
| 대응방안 | /etc/exports 파일의 옵션을 no_root_squash 에서 root_squash 로 변경 |

__MD_EOF__
