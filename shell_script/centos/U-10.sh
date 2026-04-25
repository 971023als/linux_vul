#!/bin/bash
# shell_script/centos/U-10.sh
# -----------------------------------------------------------------------------
# [U-10] /etc/(x)inetd.conf 파일 소유자 및 권한 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 네트워크 서비스 설정 파일의 무단 수정을 방지하여 서비스 오용 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-10"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""

# 점검 대상 리스트
TARGETS=("/etc/inetd.conf" "/etc/xinetd.conf")
FOUND=false

for TARGET in "${TARGETS[@]}"; do
    if [ -f "$TARGET" ]; then
        FOUND=true
        OWNER=$(stat -c "%U" "$TARGET")
        PERMS=$(stat -c "%a" "$TARGET")
        
        if [ "$OWNER" != "root" ]; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }$TARGET 소유자가 root가 아님($OWNER)"
        fi
        
        if [ "$PERMS" -gt 600 ]; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }$TARGET 권한이 600보다 큼($PERMS)"
        fi
    fi
done

# xinetd.d 디렉터리 점검 (RHEL 계열에서 다수 활용)
if [ -d "/etc/xinetd.d" ]; then
    VULN_XINETD=$(find /etc/xinetd.d -type f \( -not -user root -o -perm /0177 \) 2>/dev/null)
    if [ -n "$VULN_XINETD" ]; then
        FOUND=true
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }/etc/xinetd.d 내 일부 파일의 소유자/권한이 부적절함"
    fi
fi

if ! $FOUND; then
    RESULT="양호"
    STATUS="[양호] inetd/xinetd 설정 파일이 존재하지 않습니다(해당없음)."
elif [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] (x)inetd 설정 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root [FILE] && chmod 600 [FILE] |

__MD_EOF__
