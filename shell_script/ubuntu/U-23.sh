#!/bin/bash
# shell_script/ubuntu/U-23.sh
# -----------------------------------------------------------------------------
# [U-23] DoS 공격에 취약한 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: DoS(서비스 거부 공격)에 악용될 수 있는 불필요한 UDP/TCP 서비스 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-23"
CATEGORY="서비스 관리"
RISK="상"
ITEM="DoS 공격에 취약한 서비스 비활성화"

RESULT="양호"
STATUS=""

# 점검 대상 서비스 (echo, discard, daytime, chargen)
DOS_SERVICES=("echo" "discard" "daytime" "chargen")
VULN_SERVICES=""

# 1. xinetd.d 점검
if [ -d "/etc/xinetd.d" ]; then
    for SVC in "${DOS_SERVICES[@]}"; do
        if grep -rEi "disable\s*=\s*no" "/etc/xinetd.d/" 2>/dev/null | grep -qi "$SVC"; then
            VULN_SERVICES="${VULN_SERVICES}${SVC}(xinetd) "
            RESULT="취약"
        fi
    done
fi

# 2. inetd.conf 점검
if [ -f "/etc/inetd.conf" ]; then
    for SVC in "${DOS_SERVICES[@]}"; do
        if grep -v "^#" "/etc/inetd.conf" | grep -qi "$SVC"; then
            VULN_SERVICES="${VULN_SERVICES}${SVC}(inetd) "
            RESULT="취약"
        fi
    done
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] DoS 공격에 취약한 서비스(echo, discard 등)가 비활성화되어 있습니다."
else
    STATUS="[취약] 다음 서비스가 활성화되어 있습니다: ${VULN_SERVICES}"
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
| 대응방안 | /etc/xinetd.d/ 내 해당 서비스 파일에서 disable = yes 설정 또는 패키지 삭제 |

__MD_EOF__
