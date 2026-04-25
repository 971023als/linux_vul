#!/bin/bash
# shell_script/oracle/U-20.sh
# -----------------------------------------------------------------------------
# [U-20] Anonymous FTP 비활성화 (Oracle Linux)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 누구나 접속 가능한 익명 FTP 서비스를 차단하여 중요 데이터 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-20"
CATEGORY="서비스 관리"
RISK="상"
ITEM="Anonymous FTP 비활성화"

RESULT="양호"
STATUS=""

FTP_CONF="/etc/vsftpd/vsftpd.conf"
[ ! -f "$FTP_CONF" ] && FTP_CONF="/etc/vsftpd.conf"

if pgrep -x "vsftpd" > /dev/null; then
    if [ -f "$FTP_CONF" ]; then
        if grep -qi "anonymous_enable=YES" "$FTP_CONF"; then
            RESULT="취약"
            STATUS="vsftpd에서 Anonymous FTP가 활성화되어 있습니다."
        fi
    fi
fi

if getent passwd ftp > /dev/null 2>&1; then
    FTP_SHELL=$(getent passwd ftp | cut -d: -f7)
    if [[ "$FTP_SHELL" != *"/nologin" ]] && [[ "$FTP_SHELL" != *"/false" ]]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }ftp 계정의 셸 제한이 설정되어 있지 않습니다."
    fi
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] Anonymous FTP 서비스가 비활성화되어 있습니다."
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
| 대응방안 | vsftpd.conf에서 anonymous_enable=NO 설정 및 ftp 계정 삭제 또는 nologin 설정 |

__MD_EOF__
