#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-14"
위험도="상"
진단_항목="사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정"
대응방안="홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고, 쓰기 권한이 부여된 경우"
현황=()
진단_결과=""

start_files=(".profile" ".cshrc" ".login" ".kshrc" ".bash_profile" ".bashrc" ".bash_login")
vulnerable_files=()

# 모든 사용자 홈 디렉터리 순회
while IFS=: read -r user _ uid _ _ home _; do
    if [ -d "$home" ]; then
        for start_file in "${start_files[@]}"; do
            file_path="$home/$start_file"
            if [ -f "$file_path" ]; then
                file_uid=$(stat -c "%u" "$file_path")
                permissions=$(stat -c "%A" "$file_path")

                # 파일 소유자가 root 또는 해당 사용자가 아니거나, 다른 사용자에게 쓰기 권한이 있을 경우
                if [ "$file_uid" -ne 0 ] && [ "$file_uid" -ne "$uid" ] || [[ $permissions == *w*o ]]; then
                    vulnerable_files+=("$file_path")
                fi
            fi
        done
    fi
done < /etc/passwd

if [ ${#vulnerable_files[@]} -gt 0 ]; then
    진단_결과="취약"
    현황=("${vulnerable_files[@]}")
else
    진단_결과="양호"
    현황+=("모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for item in "${현황[@]}"; do
    echo "- $item"
done
