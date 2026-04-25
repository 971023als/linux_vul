#!/bin/bash
# shell_script/centos/U-63.sh
# -----------------------------------------------------------------------------
# [U-63] ftpusers 파일 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: FTP 서비스 이용 시 root 등 주요 계정의 접속을 제한하여 인증 정보 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-63"
CATEGORY="서비스 관리"
RISK="하"
ITEM="ftpusers 파일 설정"

RESULT="양호"
STATUS=""

# 1. RHEL 계열 vsftpd 설정 확인
CHECK_FILES=("/etc/vsftpd/ftpusers" "/etc/vsftpd/user_list" "/etc/ftpusers")
FOUND_FILE=""

for FILE in "${CHECK_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        FOUND_FILE=$FILE
        if grep -qi "^root" "$FILE"; then
            STATUS="FTP 제한 설정 파일($FILE)에 root 계정이 포함되어 있습니다."
            break
        else
            RESULT="취약"
            STATUS="FTP 제한 설정 파일($FILE)에 root 계정이 누락되었습니다."
        fi
    fi
done

if [ -z "$FOUND_FILE" ]; then
    STATUS="FTP 서비스 설정 파일이 존재하지 않습니다(서비스 미사용 권고)."
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
| 대응방안 | vsftpd.conf 확인 및 ftpusers 파일에 root 계정 추가 |

__MD_EOF__
