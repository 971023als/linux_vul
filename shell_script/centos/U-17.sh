#!/bin/bash
# shell_script/centos/U-17.sh
# -----------------------------------------------------------------------------
# [U-17] $HOME/.rhosts, hosts.equiv 사용 금지 (CentOS/RHEL/Oracle)
# -----------------------------------------------------------------------------
# - 관련 법령: ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 패스워드 없이 로그인 가능한 원격 접속 설정 파일을 제거하여 무단 접근 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-17"
CATEGORY="파일 및 디렉터리 관리"
RISK="상"
ITEM="\$HOME/.rhosts, hosts.equiv 사용 금지"

RESULT="양호"
STATUS=""

# 1. /etc/hosts.equiv 및 모든 사용자의 .rhosts 파일 검색
FILES_TO_CHECK=("/etc/hosts.equiv")
# 홈 디렉터리 내 .rhosts 추가
while IFS=: read -r _ _ _ _ _ HOME_DIR _; do
    if [ -f "$HOME_DIR/.rhosts" ]; then
        FILES_TO_CHECK+=("$HOME_DIR/.rhosts")
    fi
done < /etc/passwd

VULN_FILES=""
for FILE in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$FILE" ]; then
        # 소유자가 root 또는 해당 사용자이고, 권한이 600 이하인지 확인 필요하나
        # 기본적으로 존재 자체가 취약으로 간주되는 경우가 많음 (특히 '+' 포함 시)
        if grep -q "+" "$FILE" 2>/dev/null; then
            VULN_FILES="${VULN_FILES}${FILE}(+) "
            RESULT="취약"
        else
            # 존재만 해도 보안 가이드상 취약으로 권고하는 경우 대응
            VULN_FILES="${VULN_FILES}${FILE} "
            RESULT="취약"
        fi
    fi
done

if [[ "$RESULT" == "양호" ]]; then
    STATUS="r-command 관련 설정 파일이 존재하지 않습니다."
else
    STATUS="취약한 원격 접속 설정 파일이 발견되었습니다: ${VULN_FILES}"
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
| 대응방안 | .rhosts 및 hosts.equiv 파일 삭제 또는 내부 '+' 설정 제거 |

__MD_EOF__
