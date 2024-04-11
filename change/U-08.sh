#!/bin/bash

# /etc/shadow 파일의 경로
shadow_file="/etc/shadow"

# /etc/shadow 파일의 소유자와 권한 검사 및 조정
if [ -f "$shadow_file" ]; then
    # 소유자를 root로 설정
    chown root:root "$shadow_file"
    
    # 권한을 400으로 설정
    chmod 400 "$shadow_file"
    
    echo "U-08 /etc/shadow 파일의 소유자와 권한이 조정되었습니다."
else
    echo "U-08 /etc/shadow 파일이 존재하지 않습니다."
fi
