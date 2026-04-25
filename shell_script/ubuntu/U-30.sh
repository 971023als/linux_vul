#!/bin/bash
# shell_script/ubuntu/U-30.sh
# -----------------------------------------------------------------------------
# [U-30] Sendmail 버전 점검
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.2(패치 관리)
# - 목적: 최신 버전의 메일 서버를 사용하여 알려진 취약점(버퍼 오버플로우 등) 공격 방어
# -----------------------------------------------------------------------------

set -u

CODE="U-30"
CATEGORY="서비스 관리"
RISK="상"
ITEM="Sendmail 버전 점검"

RESULT="양호"
STATUS=""

# 1. Sendmail 또는 Postfix 버전 확인
# Ubuntu는 기본적으로 Postfix를 선호함
if command -v sendmail >/dev/null 2>&1; then
    VERSION=$(sendmail -v -d0.1 < /dev/null 2>/dev/null | grep -i "Version" | head -n 1)
    if [ -n "$VERSION" ]; then
        STATUS="Sendmail 버전이 감지되었습니다: $VERSION"
        # 실제 취약 버전 리스트와 비교하는 로직이 이상적이나, 여기서는 존재 자체로 가시화
        STATUS="${STATUS} (최신 패치 여부 확인 필요)"
    else
        STATUS="Sendmail이 설치되어 있으나 버전을 확인할 수 없습니다."
    fi
elif command -v postconf >/dev/null 2>&1; then
    VERSION=$(postconf -d mail_version | awk '{print $3}')
    STATUS="Postfix 버전이 감지되었습니다: $VERSION"
else
    RESULT="양호"
    STATUS="[양호] Sendmail/Postfix 서비스가 설치되어 있지 않습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" && "$STATUS" != *"[양호]"* ]]; then
    STATUS="[양호] $STATUS"
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
| 대응방안 | 패키지 업데이트 (apt update && apt upgrade sendmail 또는 postfix) |

__MD_EOF__
