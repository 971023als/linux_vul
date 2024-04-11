#!/bin/bash

# /etc/hosts 파일의 경로
hosts_file="/etc/hosts"

# /etc/hosts 파일의 소유자와 권한 검사 및 조정
if [ -f "$hosts_file" ]; then
    # 소유자를 root로 설정
    chown root:root "$hosts_file"
    
    # 권한을 600으로 설정
    chmod 600 "$hosts_file"
    
    echo "U-09 /etc/hosts 파일의 소유자와 권한이 조정되었습니다."
else
    echo "U-09 /etc/hosts 파일이 존재하지 않습니다."
fi
