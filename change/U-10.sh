#!/bin/bash

# 파일 소유자 및 권한 설정 함수
set_file_ownership_and_permissions() {
    file_path=$1
    if [ -f "$file_path" ]; then
        # 소유자를 root로 설정
        chown root:root "$file_path"
        # 권한을 600으로 설정
        chmod 600 "$file_path"
        echo "U-10 $file_path 파일의 소유자와 권한이 조정되었습니다."
    else
        echo "U-10 $file_path 파일이 존재하지 않습니다."
    fi
}

# 디렉터리 내 파일 소유자 및 권한 설정 함수
set_directory_files_ownership_and_permissions() {
    directory_path=$1
    if [ -d "$directory_path" ]; then
        for file_path in $directory_path/*; do
            if [ -f "$file_path" ]; then
                # 소유자를 root로 설정
                chown root:root "$file_path"
                # 권한을 600으로 설정
                chmod 600 "$file_path"
                echo "U-10 $file_path 파일의 소유자와 권한이 조정되었습니다."
            fi
        done
    else
        echo "U-10 $directory_path 디렉터리가 존재하지 않습니다."
    fi
}

# /etc/inetd.conf, /etc/xinetd.conf 파일과 /etc/xinetd.d 디렉터리 검사 및 조정
set_file_ownership_and_permissions "/etc/inetd.conf"
set_file_ownership_and_permissions "/etc/xinetd.conf"
set_directory_files_ownership_and_permissions "/etc/xinetd.d"
