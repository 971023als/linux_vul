#!/bin/bash
# shell_script/ubuntu/U-24.sh
# -----------------------------------------------------------------------------
# [U-24] NFS 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 불필요한 NFS 서비스를 차단하여 원격지에서의 비인가 데이터 접근 위험 제거
# -----------------------------------------------------------------------------

set -u

CODE="U-24"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. NFS 서비스 실행 여부 확인
if command -v systemctl >/dev/null 2>&1; then
    # nfs-kernel-server (Ubuntu/Debian 표준) 점검
    if systemctl is-active --quiet nfs-kernel-server 2>/dev/null || systemctl is-active --quiet nfs-server 2>/dev/null; then
        RESULT="취약"
        STATUS="NFS 서비스가 현재 실행 중입니다."
    fi
fi

# 2. nfs 관련 프로세스 확인
if pgrep -x "nfsd" >/dev/null 2>&1; then
    RESULT="취약"
    STATUS="${STATUS:+$STATUS / }nfsd 프로세스가 동작 중입니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] NFS 서비스가 비활성화되어 있습니다."
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
| 대응방안 | NFS 서비스 중지 및 비활성화 (systemctl stop/disable nfs-kernel-server) |

__MD_EOF__
