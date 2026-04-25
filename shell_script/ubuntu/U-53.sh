#!/bin/bash
# shell_script/ubuntu/U-53.sh
# -----------------------------------------------------------------------------
# [U-53] 사용자 shell 제한
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 로그인이 필요 없는 시스템 계정에 셸 접속을 제한하여 계정 탈취 시도 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-53"
CATEGORY="계정 관리"
RISK="하"
ITEM="사용자 shell 제한"

RESULT="양호"
STATUS=""

# 1. 로그인이 불필요한 시스템 계정 목록
# Ubuntu 기본 시스템 계정들
SYSTEM_ACCOUNTS=("bin" "sys" "daemon" "adm" "lp" "sync" "shutdown" "halt" "mail" "news" "uucp" "operator" "games" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody")

VULN_ACCOUNTS=""

for ACCOUNT in "${SYSTEM_ACCOUNTS[@]}"; do
    SHELL_VAL=$(getent passwd "$ACCOUNT" | cut -d: -f7)
    if [ -n "$SHELL_VAL" ]; then
        if [[ "$SHELL_VAL" != *"/nologin" ]] && [[ "$SHELL_VAL" != *"/false" ]]; then
            VULN_ACCOUNTS="${VULN_ACCOUNTS}${ACCOUNT}(${SHELL_VAL}) "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="모든 시스템 계정에 적절한 셸 제한(/sbin/nologin 등)이 설정되어 있습니다."
else
    STATUS="다음 시스템 계정들에 셸 접속이 허용되어 있습니다: ${VULN_ACCOUNTS}"
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
| 대응방안 | 시스템 계정의 셸을 /usr/sbin/nologin 으로 변경 (usermod -s /usr/sbin/nologin [ACCOUNT]) |

__MD_EOF__
