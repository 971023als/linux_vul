#!/bin/bash
# shell_script/ubuntu/U-21.sh
# -----------------------------------------------------------------------------
# [U-21] r 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 보안에 취약한 r-services(rsh, rlogin, rexec)를 차단하여 인증 우회 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-21"
CATEGORY="서비스 관리"
RISK="상"
ITEM="r 서비스 비활성화"

RESULT="양호"
STATUS=""

# 점검 대상 서비스 리스트
R_SERVICES=("rsh.socket" "rlogin.socket" "rexec.socket" "rsh" "rlogin" "rexec")

if command -v systemctl >/dev/null 2>&1; then
    for SVC in "${R_SERVICES[@]}"; do
        if systemctl is-active --quiet "$SVC" 2>/dev/null; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }${SVC} 서비스가 활성화되어 있습니다."
        fi
    done
fi

# inetd/xinetd 설정 확인
if [ -d "/etc/xinetd.d" ]; then
    if grep -rEq "rsh|rlogin|rexec" /etc/xinetd.d/ --exclude-dir=.* 2>/dev/null; then
        # disable = yes 인지 확인하는 로직이 필요하나, 파일 존재 자체로 경고
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }/etc/xinetd.d 에 r-services 관련 설정이 존재합니다."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] r-services(rsh, rlogin, rexec)가 비활성화되어 있습니다."
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
| 대응방안 | r-services 관련 서비스 중지 및 패키지 삭제 (apt remove rsh-server rsh-redone-server) |

__MD_EOF__
