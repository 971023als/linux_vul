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
