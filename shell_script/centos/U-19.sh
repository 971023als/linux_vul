#!/bin/bash
# shell_script/centos/U-19.sh
# -----------------------------------------------------------------------------
# [U-19] Finger 서비스 비활성화 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 사용자 정보(로그인 ID, 이름 등)를 노출하는 Finger 서비스를 차단하여 정보 수집 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-19"
CATEGORY="서비스 관리"
RISK="상"
ITEM="Finger 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. Finger 서비스 및 데몬 실행 여부 확인
if systemctl is-active --quiet finger 2>/dev/null || pgrep -x "fingerd" > /dev/null; then
    RESULT="취약"
    STATUS="Finger 서비스 또는 데몬이 실행 중입니다."
else
    # xinetd 설정 확인 (RHEL 계열 레거시 설정)
    if [ -f "/etc/xinetd.d/finger" ]; then
        if ! grep -q "disable.*=.*yes" "/etc/xinetd.d/finger"; then
            RESULT="취약"
            STATUS="xinetd 내 Finger 서비스가 활성화되어 있습니다."
        fi
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] Finger 서비스가 비활성화되어 있습니다."
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
| 대응방안 | Finger 서비스 중지 및 xinetd 설정에서 disable = yes 로 변경 |

__MD_EOF__
