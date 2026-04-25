#!/bin/bash
# shell_script/centos/U-24.sh
# -----------------------------------------------------------------------------
# [U-24] NFS 서비스 비활성화 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 NFS 서비스를 중지하여 원격 파일 시스템 접근 위험 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-24"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 NFS 관련 서비스 확인
NFS_SERVICES=("nfs-server" "nfs" "rpcbind" "mountd")
ACTIVE_SVC=""

for SVC in "${NFS_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_SVC="${ACTIVE_SVC}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="NFS 관련 서비스가 모두 비활성화되어 있습니다."
else
    STATUS="NFS 관련 서비스가 활성화되어 있습니다: ${ACTIVE_SVC} (업무상 불필요 시 중지 권고)"
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
| 대응방안 | NFS 서비스 중지 (systemctl stop nfs-server && systemctl disable nfs-server) |

__MD_EOF__
