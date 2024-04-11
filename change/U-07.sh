#!/bin/bash

# /etc/passwd 파일의 경로
passwd_file="/etc/passwd"

# /etc/passwd 파일의 소유자와 권한 검사 및 조정
if [ -f "$passwd_file" ]; then
    # 소유자를 root로 설정
    chown root:root "$passwd_file"
    
    # 권한을 644로 설정
    chmod 644 "$passwd_file"
    
    echo "U-07 /etc/passwd 파일의 소유자와 권한이 조정되었습니다."
else
    echo "U-07 /etc/passwd 파일이 존재하지 않습니다."
fi
