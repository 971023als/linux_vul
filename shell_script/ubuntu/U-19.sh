#!/bin/bash
# shell_script/ubuntu/U-19.sh
# -----------------------------------------------------------------------------
# [U-19] Finger 서비스 비활성화
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: 사용자 정보(로그인 ID, 이름 등)를 외부에 노출하는 Finger 서비스 차단
# -----------------------------------------------------------------------------

set -u

CODE="U-19"
CATEGORY="서비스 관리"
RISK="상"
ITEM="Finger 서비스 비활성화"

RESULT="양호"
STATUS=""

# 1. Finger 서비스 실행 여부 확인
# Ubuntu에서는 보통 'finger' 패키지가 있으며 서비스명도 finger 임
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet finger 2>/dev/null; then
        RESULT="취약"
        STATUS="Finger 서비스가 실행 중입니다."
    fi
fi

# 2. inetd 설정 확인
if [ -f "/etc/inetd.conf" ] && grep -qi "finger" "/etc/inetd.conf"; then
    RESULT="취약"
    STATUS="${STATUS:+${STATUS} / }/etc/inetd.conf 에 finger 서비스가 활성화되어 있습니다."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] Finger 서비스가 비활성화되어 있습니다."
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
| 대응방안 | Finger 서비스 중지 및 비활성화 (systemctl stop/disable finger) |

__MD_EOF__
