#!/bin/bash
# shell_script/ubuntu/U-17.sh
# -----------------------------------------------------------------------------
# [U-17] $HOME/.rhosts, hosts.equiv 사용 금지
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.4.7(원격접근 통제)
# - 목적: 인증 없이 로그인할 수 있는 r-services의 신뢰 설정을 차단하여 무단 접근 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-17"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="\$HOME/.rhosts, hosts.equiv 사용 금지"

RESULT="양호"
STATUS=""

# 1. /etc/hosts.equiv 점검
if [ -f "/etc/hosts.equiv" ]; then
    RESULT="취약"
    STATUS="/etc/hosts.equiv 파일이 존재합니다."
fi

# 2. 사용자별 .rhosts 점검
VULN_RHOSTS=""
while IFS=: read -r username _ _ _ _ homedir _; do
    if [ -f "$homedir/.rhosts" ]; then
        VULN_RHOSTS="${VULN_RHOSTS}${username}($homedir/.rhosts)\n"
        RESULT="취약"
    fi
done < /etc/passwd

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] r-services 관련 신뢰 설정 파일(.rhosts, hosts.equiv)이 존재하지 않습니다."
else
    STATUS="[취약] $STATUS${VULN_RHOSTS:+\n사용자별 .rhosts 발견:\n$VULN_RHOSTS}"
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
| 대응방안 | .rhosts 및 hosts.equiv 파일 삭제 |

__MD_EOF__
