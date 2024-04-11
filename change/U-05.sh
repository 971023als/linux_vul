#!/bin/bash

# 글로벌 환경 설정 파일
global_files=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

# 수정 함수
remove_dot_from_path() {
    local file=$1
    # PATH에서 '.' 제거
    if grep -E 'PATH=.*(\.|::)' "$file" > /dev/null; then
        echo "Modifying $file to remove '.' from PATH..."
        # 'sed'를 사용하여 PATH 변수 내의 '.' 제거
        sed -i -e 's/\b\.\b//g' -e 's/::/:/g' -e 's/:$//g' -e 's/^://g' "$file"
    fi
}

# 글로벌 설정 파일 검사 및 수정
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        remove_dot_from_path "$file"
    fi
done

# 사용자 홈 디렉터리 설정 파일 검사 및 수정
getent passwd | while IFS=: read -r name password uid gid gecos home shell; do
    user_files=(
        ".profile"
        ".cshrc"
        ".login"
        ".kshrc"
        ".bash_profile"
        ".bashrc"
        ".bash_login"
    )
    for user_file in "${user_files[@]}"; do
        full_path="$home/$user_file"
        if [ -f "$full_path" ]; then
            remove_dot_from_path "$full_path"
        fi
    done
done

echo ""U-05 PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정."
