#!/bin/bash

update_path_in_file() {
    local file=$1
    if [ -f "$file" ]; then
        # PATH에서 '.' 제거
        sed -i '/^PATH/s/:\.//g; /^PATH/s/\.:/:/g; /^PATH/s/\.$//g; /^PATH/s/^\.://g' "$file"
        echo "$file 내의 PATH 환경변수에서 '.' 제거 완료"
    fi
}

global_files=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

user_files=(
    ".profile"
    ".cshrc"
    ".login"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)

# 글로벌 설정 파일 수정
for file in "${global_files[@]}"; do
    update_path_in_file "$file"
done

# 사용자 홈 디렉터리 설정 파일 수정
while IFS=: read -r username _ _ _ _ homedir _; do
    for user_file in "${user_files[@]}"; do
        if [ -d "$homedir" ]; then
            update_path_in_file "$homedir/$user_file"
        fi
    done
done < /etc/passwd

echo "모든 관련 파일에서 PATH 환경변수 수정 완료."
