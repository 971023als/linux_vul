#!/bin/bash
# shell_script/centos/U-11.sh
# -----------------------------------------------------------------------------
# [U-11] /etc/rsyslog.conf 파일 소유자 및 권한 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.10.1(로깅 및 감시), 2.6.1(시스템 하드닝)
# - 목적: 로그 설정 파일의 무단 수정을 방지하여 침적 은폐 목적의 로그 중단 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-11"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="/etc/rsyslog.conf 파일 소유자 및 권한 설정"

RESULT="양호"
STATUS=""

# 점검 대상 리스트 (RHEL 계열은 rsyslog 가 표준)
TARGETS=("/etc/rsyslog.conf" "/etc/syslog.conf")
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
        
        if [ "$PERMS" -gt 644 ]; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }$TARGET 권한이 644보다 큰 $PERMS 입니다."
        fi
    fi
done

if ! $FOUND; then
    RESULT="취약"
    STATUS="rsyslog.conf 또는 syslog.conf 파일을 찾을 수 없습니다."
elif [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] 로깅 설정 파일의 소유자 및 권한 설정이 적절합니다."
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
| 대응방안 | chown root ${TARGETS[0]} && chmod 644 ${TARGETS[0]} |

__MD_EOF__
