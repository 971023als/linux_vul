#!/bin/bash

exports_file="/etc/exports"

if [ -f "$exports_file" ]; then
    # 소유자를 root으로 변경
    sudo chown root:root "$exports_file"
    # 권한을 644로 설정
    sudo chmod 644 "$exports_file"
    
    echo "U-69 /etc/exports 파일의 소유자와 권한을 적절하게 설정하였습니다."
else
    echo "U-69 /etc/exports 파일이 존재하지 않습니다. NFS가 설치되지 않았거나 다른 위치에 설정 파일이 있을 수 있습니다."
fi
