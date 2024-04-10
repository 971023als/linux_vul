#!/bin/bash

# /etc/passwd에서 패스워드를 /etc/shadow로 이동
passwd -l root
awk -F: '($2 != "x") {print $1}' /etc/passwd | while read user; do
    echo "패스워드를 쉐도우 파일로 이동 중: $user"
    passwd -l "$user"
done

# /etc/shadow 파일 권한 설정
chmod 640 /etc/shadow
echo "/etc/shadow 파일의 권한을 640으로 설정했습니다."

# 권한 변경 후 /etc/shadow 파일 권한 확인
if [ $(stat -c "%a" /etc/shadow) == "640" ]; then
    echo "/etc/shadow 파일의 권한이 적절히 설정되었습니다."
else
    echo "/etc/shadow 파일의 권한 설정에 실패했습니다."
fi
