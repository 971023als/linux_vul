#!/bin/bash
# shell_script/ubuntu/U-01.sh
# -----------------------------------------------------------------------------
# [U-01] root 계정 원격 접속 제한
# -----------------------------------------------------------------------------
# - 관련 법령: 전자금융감독규정 제13조(비밀보호), ISMS-P 2.4.7(원격접근 통제)
# - 목적: 원격 터미널 서비스를 통한 root 직접 접속을 차단하여 무단 접근 위협 최소화
# -----------------------------------------------------------------------------

set -u

CODE="U-01"
CATEGORY="계정 관리"
RISK="상"
ITEM="root 계정 원격 접속 제한"

RESULT="양호"
STATUS=""
DETAILS=""

# 1. Telnet 점검 (시스템 부하 최소화를 위해 순차 점검)
# Telnet은 보통 inetd/xinetd 또는 단독 서비스로 실행됨
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet telnet.socket 2>/dev/null || systemctl is-active --quiet telnet 2>/dev/null; then
        RESULT="취약"
        STATUS="Telnet 서비스가 활성화되어 있습니다."
    fi
fi

# 2. SSH PermitRootLogin 점검
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONFIG" ]; then
    # PermitRootLogin 설정값 추출 (주석 제외)
    ROOT_LOGIN_VAL=$(grep -i "^PermitRootLogin" "$SSHD_CONFIG" | awk '{print $2}' | tail -n 1)
    
    if [[ -z "$ROOT_LOGIN_VAL" ]]; then
        # 설정이 없으면 기본값(일반적으로 prohibit-password 또는 yes)에 따라 판단
        # 보안 가이드라인상 명시적 'no'가 아니면 취약으로 간주하는 경우가 많음
        STATUS="${STATUS:+${STATUS} / }SSH PermitRootLogin 설정이 명시되어 있지 않습니다(Default)."
        # Ubuntu 기본값은 prohibit-password(키 기반 허용)이므로 상황에 따라 판단 필요하나, 'no' 권고
        RESULT="취약"
    elif [[ "$ROOT_LOGIN_VAL" == "yes" || "$ROOT_LOGIN_VAL" == "without-password" ]]; then
        RESULT="취약"
        STATUS="${STATUS:+${STATUS} / }SSH root 직접 접속이 허용되고 있습니다(PermitRootLogin ${ROOT_LOGIN_VAL})."
    else
        STATUS="${STATUS:+${STATUS} / }SSH root 접속 제한이 설정되어 있습니다($ROOT_LOGIN_VAL)."
    fi
else
    STATUS="${STATUS:+${STATUS} / }sshd_config 파일을 찾을 수 없습니다."
fi

# 최종 판정 문구 정리
if [[ "$RESULT" == "양호" ]]; then
    STATUS="[양호] Telnet 서비스가 비활성화되어 있고, SSH root 접속 제한이 적절히 설정되어 있습니다."
else
    STATUS="[취약] $STATUS"
fi

# ==== 표준 출력 (Markdown) ====
cat << __MD_EOF__
# ${CODE}: ${ITEM}

| 