#!/bin/bash

분류="파일 및 디렉터리 관리"
코드="U-05"
위험도="상"
진단_항목="root홈, 패스 디렉터리 권한 및 패스 설정"
대응방안="PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정"
현황=()

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

# 글로벌 설정 파일 검사
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file"; then
            현황+=("$file 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")
        fi
    fi
done

# 사용자 홈 디렉터리 설정 파일 검사
while IFS=: read -r username _ _ _ _ homedir _; do
    for user_file in "${user_files[@]}"; do
        file_path="$homedir/$user_file"
        if [ -f "$file_path" ]; then
            if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file_path"; then
                현황+=("$file_path 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")
            fi
        fi
    done
done < /etc/passwd

# 진단 결과 설정
if [ ${#현황[@]} -eq 0 ]; then
    진단_결과="양호"
else
    진단_결과="취약"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for 사항 in "${현황[@]}"; do
    echo "- $사항"
done
