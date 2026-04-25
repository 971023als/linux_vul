#!/bin/bash
# shell_script/ubuntu/U-29.sh
# -----------------------------------------------------------------------------
# [U-29] tftp, talk 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 보안에 취약한 파일 전송(tftp) 및 메시지(talk) 서비스 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-29"
CATEGORY="서비스 관리"
RISK="상"
ITEM="tftp, talk 비활성화"

RESULT="양호"
STATUS=""

# 1. tftp, talk 서비스 점검
VULN_SERVICES=""
if command -v systemctl >/dev/null 2>&1; then
    for SVC in "tftp" "talk" "ntalk"; do
        if systemctl is-active --quiet "$SVC" 2>/dev/null; then
            RESULT="취약"
            VULN_SERVICES="${VULN_SERVICES}${SVC} "
        fi
    done
fi

# 2. xinetd/inetd 점검
if [ -d "/etc/xinetd.d" ]; then
    for SVC in "tftp" "talk" "ntalk"; do
        if grep -rEi "disable\s*=\s*no" "/etc/xinetd.d/" 2>/dev/null | grep -qi "$SVC"; then
            RESULT="취약"
            VULN_SERVICES="${VULN_SERVICES}${SVC}(xinetd) "
        fi
    done
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] tftp, talk 서비스가 비활성화되어 있습니다."
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
| 대응방안 | 해당 서비스 중지 및 패키지 삭제 (apt remove tftpd talkd) |

__MD_EOF__
