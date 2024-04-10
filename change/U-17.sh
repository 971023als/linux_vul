#!/bin/bash

# /etc/hosts.equiv 파일 삭제
if [ -e "/etc/hosts.equiv" ]; then
    rm -f "/etc/hosts.equiv"
    echo "/etc/hosts.equiv 파일이 삭제되었습니다."
fi

# 사용자별 .rhosts 파일 삭제
while IFS=: read -r username _ _ _ _ homedir _; do
    if [ -d "$homedir" ] && [ "$homedir" != "/sbin/nologin" ] && [ "$homedir" != "/bin/false" ]; then
        rhosts_path="$homedir/.rhosts"
        if [ -e "$rhosts_path" ]; then
            rm -f "$rhosts_path"
            echo "$rhosts_path 파일이 삭제되었습니다."
        fi
    fi
done < /etc/passwd

echo "모든 /etc/hosts.equiv 및 사용자별 .rhosts 파일이 시스템에서 삭제되었습니다."
