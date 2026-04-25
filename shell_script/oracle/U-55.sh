#!/bin/bash
# shell_script/oracle/U-55.sh
# -----------------------------------------------------------------------------
# [U-55] NFS 설정 파일 권한 설정 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: NFS 설정 파일(/etc/exports)의 권한을 제한하여 비인가된 자원 공유 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-55"
CATEGORY="서비스 관리"
RISK="중"
ITEM="NFS 설정 파일 권한 설정"

RESULT="양호"
STATUS=""
TARGET="/etc/exports"

if [ -f "$TARGET" ]; then
    OWNER=$(stat -c %U "$TARGET")
    PERM=$(stat -c %a "$TARGET")
    
    if [ "$OWNER" == "root" ] && [ "$PERM" -le 644 ]; then
        STATUS="/etc/exports 파일의 소유자(root) 및 권한(${PERM})이 적절합니다."
    else
        RESULT="취약"
        STATUS="/etc/exports 파일의 설정이 부적절합니다: 소유자(${OWNER}), 권한(${PERM})"
    fi
else
    STATUS="/etc/exports 파일이 존재하지 않습니다(NFS 미사용)."
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
| 대응방안 | chown root /etc/exports && chmod 644 /etc/exports |

__MD_EOF__
