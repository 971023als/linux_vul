#!/bin/bash
# shell_script/centos/U-25.sh
# -----------------------------------------------------------------------------
# [U-25] NFS 접근 제한 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: NFS 공유 시 접근 가능한 호스트를 제한하고 root 권한을 매핑하여 데이터 노출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-25"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS 접근 제한"

RESULT="양호"
STATUS=""
TARGET="/etc/exports"

if [ -f "$TARGET" ]; then
    # 1. 모든 호스트(*) 허용 여부 점검
    if grep -v "^#" "$TARGET" | grep -q "\*"; then
        RESULT="취약"
        STATUS="NFS 설정에 모든 호스트(*) 접근이 허용되어 있습니다."
    fi
    
    # 2. root_squash 옵션 누락 여부 점검 (no_root_squash가 있으면 취약)
    if grep -v "^#" "$TARGET" | grep -q "no_root_squash"; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }no_root_squash 옵션이 설정되어 있어 root 권한 탈취 위험이 있습니다."
    fi
else
    STATUS="NFS 설정 파일($TARGET)이 존재하지 않습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    [ -z "$STATUS" ] && STATUS="NFS 접근 제한 설정이 적절합니다."
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
| 대응방안 | /etc/exports 에서 특정 IP만 허용하고 root_squash 옵션 적용 |

__MD_EOF__
