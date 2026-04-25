#!/bin/bash
# shell_script/ubuntu/U-20.sh
# -----------------------------------------------------------------------------
# [U-20] Anonymous FTP 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 익명 사용자의 FTP 접근을 차단하여 무단 파일 업로드/다운로드 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-20"
CATEGORY="서비스 관리"
RISK="상"
ITEM="Anonymous FTP 비활성화"

RESULT="양호"
STATUS=""

# 점검 대상 설정 파일
FTP_CONFIGS=("/etc/vsftpd.conf" "/etc/proftpd/proftpd.conf")
FTP_FOUND=false

for CONF in "${FTP_CONFIGS[@]}"; do
    if [ -f "$CONF" ]; then
        FTP_FOUND=true
        # anonymous_enable=YES 또는 <Anonymous> 블록 확인
        if grep -qi "anonymous_enable=YES" "$CONF" || grep -qi "<Anonymous" "$CONF"; then
            RESULT="취약"
            STATUS="${STATUS:+${STATUS} / }$CONF 파일에 익명 접속이 허용되어 있습니다."
        fi
    fi
done

# 'ftp' 계정 존재 여부 확인 (일반적으로 익명 FTP용 계정)
if getent passwd ftp >/dev/null 2>&1; then
    STATUS="${STATUS:+${STATUS} / }시스템에 ftp 계정이 존재합니다(사용 여부 확인 필요)."
fi

if ! $FTP_FOUND && ! getent passwd ftp >/dev/null 2>&1; then
    STATUS="[양호] FTP 서비스가 설치되어 있지 않거나 익명 계정이 없습니다."
elif [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] FTP 서비스 설정에서 익명 접속이 적절히 차단되어 있습니다."
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
| 대응방안 | FTP 설정 파일(vsftpd.conf 등)에서 anonymous_enable=NO 설정 |

__MD_EOF__
