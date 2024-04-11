#!/bin/bash

# /etc/services 파일의 경로
services_file="/etc/services"

# /etc/services 파일의 소유자와 권한 검사 및 조정
if [ -f "$services_file" ]; then
    # 소유자를 root로 설정
    chown root:root "$services_file"
    
    # 권한을 644로 설정
    chmod 644 "$services_file"
    
    echo "U-12 $services_file 파일의 소유자와 권한이 조정되었습니다."
else
    echo "U-12 $services_file 파일이 존재하지 않습니다."
fi
