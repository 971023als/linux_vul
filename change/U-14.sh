#!/bin/bash

# 검사 대상 환경 파일 목록
start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")

# 모든 사용자의 홈 디렉터리를 순회
while IFS=: read -r username _ _ _ _ home _; do
    if [ -d "$home" ]; then  # 홈 디렉터리가 존재하는 경우
        for file in "${start_files[@]}"; do
            file_path="$home/$file"
            if [ -f "$file_path" ]; then  # 파일이 존재하는 경우
                # 파일 소유자를 해당 사용자로 변경
                chown "$username":"$username" "$file_path"
                # 다른 사용자에게 쓰기 권한 제거 (소유자와 그룹에게만 쓰기 권한 유지)
                chmod o-w "$file_path"
                echo "U-14 $file_path 파일의 소유자를 $username 으로 변경하고, 다른 사용자의 쓰기 권한을 제거했습니다."
            fi
        done
    fi
done < /etc/passwd
