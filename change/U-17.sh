#!/bin/bash

# /etc/hosts.equiv 파일 검사 및 제거
if [ -f "/etc/hosts.equiv" ]; then
    echo "/etc/hosts.equiv 파일이 존재합니다. 제거하는 것이 권장됩니다."
    rm -f "/etc/hosts.equiv"
fi

# 각 사용자 홈 디렉터리 내의 .rhosts 파일 검사 및 제거
getent passwd | while IFS=: read -r user _ _ _ _ home _; do
    if [ -d "$home" ]; then
        rhosts="$home/.rhosts"
        if [ -f "$rhosts" ]; then
            echo "$user 사용자의 홈 디렉터리에 .rhosts 파일이 존재합니다. 제거하는 것이 권장됩니다."
            rm -f "$rhosts"
        fi
    fi
done

echo "U-17 hosts.equiv 및 .rhosts 파일에 대한 조치가 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-17"
_change_item="/etc/hosts.equiv 파일이 존재합니다. 제거"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
