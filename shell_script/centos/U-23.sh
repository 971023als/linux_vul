#!/bin/bash
# shell_script/centos/U-23.sh
# -----------------------------------------------------------------------------
# [U-23] DoS 공격에 취약한 서비스 비활성화 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: echo, discard, daytime, chargen 등 DoS 공격에 취약한 서비스를 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-23"
CATEGORY="서비스 관리"
RISK="상"
ITEM="DoS 공격에 취약한 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. 점검 대상 서비스 리스트
DOS_SERVICES=("echo" "discard" "daytime" "chargen")
ACTIVE_SVC=""

for SVC in "${DOS_SERVICES[@]}"; do
    # systemd 서비스 및 xinetd 설정 확인
    if systemctl is-active --quiet "$SVC" 2>/dev/null; then
        ACTIVE_SVC="${ACTIVE_SVC}${SVC} "
        RESULT="취약"
    fi
    
    # xinetd 설정 파일 확인 (RHEL 계열에서 주로 사용)
    if [ -f "/etc/xinetd.d/$SVC" ]; then
        if ! grep -q "disable.*=.*yes" "/etc/xinetd.d/$SVC"; then
            ACTIVE_SVC="${ACTIVE_SVC}${SVC}(xinetd) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="DoS 공격에 취약한 서비스들이 모두 비활성화되어 있습니다."
else
    STATUS="DoS 공격에 취약한 서비스가 활성화되어 있습니다: ${ACTIVE_SVC}"
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
| 대응방안 | 불필요한 DoS 서비스 중지 및 xinetd 설정에서 disable = yes 로 변경 |

__MD_EOF__
