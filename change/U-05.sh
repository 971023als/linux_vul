#!/bin/bash

echo "시스템의 PATH 환경변수 설정을 검사합니다."

# 글로벌 설정 파일 목록
GLOBAL_FILES=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

# 사용자별 설정 파일 목록
USER_FILES=(
    ".profile"
    ".cshrc"
    ".login"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)

# 글로벌 설정 파일에서 검사
for file in "${GLOBAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        if grep -E '\b\.\b|(^|:)\.(:|$)' "$file" > /dev/null; then
            echo "경고: $file 파일 내의 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다."
        fi
    fi
done

# 모든 사용자의 홈 디렉터리에서 검사
while IFS=: read -r user _ _ _ _ home _; do
    for file in "${USER_FILES[@]}"; do
        full_path="$home/$file"
        if [ -f "$full_path" ]; then
            if grep -E '\b\.\b|(^|:)\.(:|$)' "$full_path" > /dev/null; then
                echo "경고: $full_path 파일 내의 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다."
            fi
        fi
    done
done < /etc/passwd

echo "PATH 환경변수 설정 검사가 완료되었습니다."
