#!/bin/bash
# shell_script/ubuntu/U-57.sh
# -----------------------------------------------------------------------------
# [U-57] 원격 서비스 암호화 여부
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제12조(데이터 보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 평문 통신 서비스(Telnet, FTP 등)를 차단하고 암호화 서비스(SSH, SFTP) 사용 강제
# -----------------------------------------------------------------------------

set -u

CODE="U-57"
CATEGORY="서비스 관리"
RISK="상"
ITEM="원격 서비스 암호화 여부"

RESULT="양호"
STATUS=""

# 1. 취약한 평문 서비스 실행 여부 확인
VULN_SERVICES=("telnet" "ftp" "rsh" "rlogin" "rexec")
ACTIVE_VULN=""

for SVC in "${VULN_SERVICES[@]}"; do
    # 서비스 이름 또는 데몬 존재 여부 확인
    if systemctl is-active --quiet "$SVC" 2>/dev/null || pgrep -x "$SVC" > /dev/null; then
        ACTIVE_VULN="${ACTIVE_VULN}${SVC} "
        RESULT="취약"
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="취약한 평문 원격 서비스가 비활성화되어 있습니다. (SSH 사용 권고)"
else
    STATUS="취약한 평문 원격 서비스(${ACTIVE_VULN})가 활성화되어 있습니다. 암호화 서비스(SSH, SFTP)로 대체가 필요합니다."
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
| 대응방안 | Telnet, FTP 등 평문 서비스 중지 및 SSH/SFTP 전환 |

__MD_EOF__
