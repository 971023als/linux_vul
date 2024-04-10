#!/bin/bash

# 파일 및 디렉터리 권한 설정 함수
set_ownership_and_permissions() {
    local target=$1
    if [ -e "$target" ]; then
        # 소유자를 root로 변경
        chown root "$target"
        
        # 파일일 경우 권한을 600으로, 디렉터리일 경우 내부 파일들 권한을 600으로 설정
        if [ -f "$target" ]; then
            chmod 600 "$target"
        elif [ -d "$target" ]; then
            chmod 600 "$target"/*
        fi

        echo "$target 의 소유자와 권한이 적절히 설정되었습니다."
    else
        echo "$target 은(는) 존재하지 않습니다."
    fi
}

# /etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일 소유자 및 권한 설정
files_and_directories_to_update=(
    '/etc/inetd.conf'
    '/etc/xinetd.conf'
    '/etc/xinetd.d'
)

for item in "${files_and_directories_to_update[@]}"; do
    set_ownership_and_permissions "$item"
done

echo "모든 지정된 파일 및 디렉터리의 소유자와 권한이 업데이트 되었습니다."
