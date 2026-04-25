#!/bin/bash
# shell_script/ubuntu/U-34.sh
# -----------------------------------------------------------------------------
# [U-34] DNS 존 트랜스퍼 설정
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 외부인에 의한 도메인 정보(서버 목록 등) 대량 유출 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-34"
CATEGORY="서비스 관리"
RISK="상"
ITEM="DNS 존 트랜스퍼 설정"

RESULT="양호"
STATUS=""

# BIND 설정 파일 경로 (Ubuntu)
NAMED_CONF="/etc/bind/named.conf.options"
[ ! -f "$NAMED_CONF" ] && NAMED_CONF="/etc/bind/named.conf"

if [ -f "$NAMED_CONF" ]; then
    # allow-transfer { any; }; 또는 allow-transfer 가 없는지 확인
    if grep -rEi "allow-transfer" /etc/bind/ 2>/dev/null | grep -qi "any"; then
        RESULT="취약"
        STATUS="DNS 설정에서 모든 사용자(any)에게 존 트랜스퍼를 허용하고 있습니다."
    elif ! grep -rEi "allow-transfer" /etc/bind/ 2>/dev/null | grep -q "allow-transfer"; then
        # 명시적인 제한이 없으면 기본값에 따라 위험할 수 있음
        RESULT="취약"
        STATUS="DNS 설정에 allow-transfer 제한 설정이 명시되어 있지 않습니다."
    fi
else
    STATUS="DNS(BIND) 서비스 설정 파일을 찾을 수 없습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] "
    [ -z "$STATUS" ] && STATUS="[양호] DNS 존 트랜스퍼가 적절히 제한되어 있습니다."
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
| 대응방안 | named.conf.options 또는 zone 설정에서 allow-transfer { none; }; 또는 특정 IP로 제한 |

__MD_EOF__
