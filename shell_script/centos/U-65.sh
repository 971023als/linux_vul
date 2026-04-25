#!/bin/bash
# shell_script/centos/U-65.sh
# -----------------------------------------------------------------------------
# [U-65] 로그 파일 권한 설정 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제25조(로그기록 및 관리), ISMS-P 2.10.1(로깅 및 감시)
# - 목적: 로그 파일의 권한을 제한하여 비인가된 사용자의 로그 위변조 및 삭제 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-65"
CATEGORY="로그 관리"
RISK="중"
ITEM="로그 파일 권한 설정"

RESULT="양호"
STATUS=""

# 1. RHEL 주요 로그 파일 리스트
LOG_FILES=("/var/log/messages" "/var/log/secure" "/var/log/maillog" "/var/log/cron" "/var/log/boot.log")
VULN_LOGS=""

for LOG in "${LOG_FILES[@]}"; do
    if [ -f "$LOG" ]; then
        PERM=$(stat -c %a "$LOG")
        # 타인(Others)에게 쓰기 권한이 있거나, 640을 초과하는지 확인
        # 보안 가이드: 640 이하 (일반 사용자는 읽기 불가능해야 함)
        if [ "$PERM" -gt 640 ]; then
            RESULT="취약"
            VULN_LOGS="${VULN_LOGS}${LOG}(${PERM}) "
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="주요 로그 파일의 권한이 적절히 제한되어 있습니다."
else
    STATUS="다음 로그 파일들의 권한 설정이 취약합니다: ${VULN_LOGS}"
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
| 대응방안 | chmod 640 [로그파일] 명령으로 권한 축소 |

__MD_EOF__
