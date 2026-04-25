#!/bin/bash
# shell_script/ubuntu/U-56.sh
# -----------------------------------------------------------------------------
# [U-56] NFS 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 NFS 서비스를 중지하여 원격 파일 시스템 접근 위험 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-56"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. NFS 서비스(서버 및 클라이언트 관련) 실행 여부 확인
NFS_SERVICES=("nfs-kernel-server" "nfs-common" "rpcbind")
ACTIVE_SERVICES=""

for SVC in "${NFS_SERVICES[@]}"; do
    if systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_SERVICES="${ACTIVE_SERVICES}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="NFS 관련 서비스가 모두 비활성화되어 있습니다."
else
    # NFS를 실제 사용하는 경우를 위해 '수동 검토' 의견 포함
    STATUS="NFS 관련 서비스(${ACTIVE_SERVICES})가 활성화되어 있습니다. 업무상 불필요 시 중지 권고."
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
| 대응방안 | 불필요한 NFS 서비스 중지 (systemctl stop [SERVICE] && systemctl disable [SERVICE]) |

__MD_EOF__
