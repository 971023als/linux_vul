#!/bin/bash
# shell_script/ubuntu/U-25.sh
# -----------------------------------------------------------------------------
# [U-25] NFS 접근 통제
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제15조(네트워크 보안), ISMS-P 2.6.1(시스템 하드닝)
# - 목적: NFS 공유 설정 시 허용 대상을 제한하여 권한 없는 자의 데이터 접근 방지
# -----------------------------------------------------------------------------

set -u

CODE="U-25"
CATEGORY="서비스 관리"
RISK="상"
ITEM="NFS 접근 통제"

RESULT="양호"
STATUS=""
EXPORTS="/etc/exports"

if [ -f "$EXPORTS" ]; then
    # 1. 모든 호스트(*) 허용 확인
    if grep -v "^#" "$EXPORTS" | grep -q "\*"; then
        RESULT="취약"
        STATUS="NFS 공유 설정에 모든 호스트(*) 허용이 포함되어 있습니다."
    fi
    
    # 2. insecure 옵션 또는 no_root_squash 확인
    if grep -v "^#" "$EXPORTS" | grep -q "no_root_squash"; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }no_root_squash 옵션이 사용되고 있습니다."
    fi
else
    STATUS="/etc/exports 파일이 존재하지 않습니다(해당없음)."
fi

if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] "
    [ -z "$STATUS" ] && STATUS="[양호] NFS 접근 통제 설정이 적절하거나 서비스가 없습니다."
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
| 대응방안 | /etc/exports 에서 특정 IP/대역으로 제한하고 root_squash 옵션 적용 |

__MD_EOF__
