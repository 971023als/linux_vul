#!/bin/bash
# shell_script/ubuntu/U-04.sh
# -----------------------------------------------------------------------------
# [U-04] 패스워드 파일 보호
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 해시화된 패스워드를 별도의 shadow 파일에 저장하여 일반 사용자의 접근 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-04"
CATEGORY="계정 관리"
RISK="상"
ITEM="패스워드 파일 보호"

RESULT="양호"
STATUS=""

# 1. /etc/passwd 내 shadow 패스워드 사용 여부 확인 ('x' 표시 확인)
if [ -f "/etc/passwd" ]; then
    # 두 번째 필드가 x가 아닌 계정이 있는지 확인 (비밀번호가 passwd 파일에 직접 기록된 경우)
    VULN_ACCOUNTS=$(awk -F: '$2 != "x" && $2 != "*" && $2 != "!" {print $1}' /etc/passwd)
    
    if [ -z "$VULN_ACCOUNTS" ]; then
        STATUS="모든 계정이 shadow 패스워드를 사용하고 있습니다."
    else
        RESULT="취약"
        STATUS="일부 계정이 shadow 패스워드를 사용하지 않습니다: $VULN_ACCOUNTS"
    fi
else
    RESULT="취약"
    STATUS="/etc/passwd 파일을 찾을 수 없습니다."
fi

# 2. /etc/shadow 파일 존재 여부 확인
if [ ! -f "/etc/shadow" ]; then
    RESULT="취약"
    STATUS="${STATUS:+${STATUS} / }/etc/shadow 파일이 존재하지 않습니다."
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
| 대응방안 | 1. pwconv 명령을 수행하여 shadow 패스워드 체계로 전환<br>2. /etc/passwd 파일의 패스워드 필드를 'x'로 수정 |

__MD_EOF__
