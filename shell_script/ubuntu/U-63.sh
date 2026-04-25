#!/bin/bash
# shell_script/ubuntu/U-63.sh
# -----------------------------------------------------------------------------
# [U-63] ftpusers 파일 설정
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: root 등 주요 계정의 FTP 접속을 명시적으로 차단하여 계정 탈취 위험 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-63"
CATEGORY="서비스 관리"
RISK="하"
ITEM="ftpusers 파일 설정"

RESULT="양호"
STATUS=""

# 1. 점검 대상 파일 (vsftpd, proftpd 등 공통)
FTPUSERS_FILES=("/etc/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd/ftpusers")
FOUND=false

for FILE in "${FTPUSERS_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        FOUND=true
        if grep -qi "^root" "$FILE"; then
            STATUS="[양호] $FILE 에 root 계정이 적절히 차단 설정되어 있습니다."
        else
            RESULT="취약"
            STATUS="[취약] $FILE 에 root 계정 차단 설정이 누락되었습니다."
        fi
        break
    fi
done

if ! $FOUND; then
    STATUS="[양호] FTP 서비스 설정 파일(ftpusers)이 존재하지 않습니다(서비스 미사용)."
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
| 대응방안 | /etc/ftpusers 파일에 root 및 시스템 계정 추가 |

__MD_EOF__
