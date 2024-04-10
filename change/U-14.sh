#!/bin/bash

# 시작 파일 목록
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")

# 모든 사용자 홈 디렉터리 순회
while IFS=: read -r user _ uid gid _ home _; do
    if [ -d "$home" ]; then
        for start_file in "${start_files[@]}"; do
            file_path="$home/$start_file"
            if [ -f "$file_path" ]; then
                # 파일 소유자를 사용자로 변경
                chown $uid:$gid "$file_path"
                # 다른 사용자에게 쓰기 권한 제거 (소유자와 그룹에게만 읽기 및 쓰기 권한 부여)
                chmod 640 "$file_path"
                echo "$file_path의 소유자와 권한이 수정되었습니다."
            fi
        done
    fi
done < /etc/passwd

echo "모든 사용자의 홈 디렉터리 시작파일 및 환경파일에 대한 소유자와 권한 설정 조치가 완료되었습니다."
