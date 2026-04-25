#!/bin/bash

# /etc/passwd 파일에서 쉐도우 패스워드 사용 여부 확인
shadow_needed=false
while IFS=: read -r user pass rest; do
    if [ "$pass" != "x" ]; then
        shadow_needed=true
        break
    fi
done </etc/passwd

# 쉐도우 패스워드 필요한 경우 조치 실행
if [ "$shadow_needed" = true ]; then
    echo "일부 계정이 쉐도우 패스워드를 사용하고 있지 않습니다."
    echo "쉐도우 패스워드 사용으로 전환합니다."

    # /etc/passwd 파일의 모든 사용자 패스워드를 /etc/shadow로 옮김
    pwconv

    echo "쉐도우 패스워드 사용으로 전환 완료."
else
    echo "모든 계정이 쉐도우 패스워드를 사용하고 있습니다."
fi

# /etc/shadow 파일 권한 검사 및 설정
if [ -f /etc/shadow ]; then
    chmod 400 /etc/shadow
    echo "U-04 /etc/shadow 파일의 권한을 안전하게 설정하였습니다."
else
    echo "U-04 /etc/shadow 파일이 존재하지 않습니다. 문제가 있을 수 있으니 확인이 필요합니다."
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-04"
_change_item="일부 계정이 쉐도우 패스워드를 사용하고 있지 않습니다."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
