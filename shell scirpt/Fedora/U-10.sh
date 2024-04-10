#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-10"
위험도="상"
진단_항목="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
대응방안="/etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 미만인 경우"
현황=()
진단_결과=""

# 파일 소유자 및 권한 검사 함수
check_file_ownership_and_permissions() {
    file_path=$1
    if [ ! -e "$file_path" ]; then
        return 1 # 파일이 존재하지 않음
    fi
    
    mode=$(stat -c "%a" "$file_path")
    owner_uid=$(stat -c "%u" "$file_path")
    
    if [ "$owner_uid" -eq 0 ] && [ "$mode" -lt 600 ]; then
        return 0 # 조건 충족
    else
        return 2 # 조건 불충족
    fi
}

# 디렉터리 내 파일 소유자 및 권한 검사 함수
check_directory_files_ownership_and_permissions() {
    directory_path=$1
    if [ ! -d "$directory_path" ]; then
        return 1 # 디렉터리가 존재하지 않음
    fi
    
    for file_path in "$directory_path"/*; do
        if ! check_file_ownership_and_permissions "$file_path"; then
            return 2 # 조건 불충족
        fi
    done
    
    return 0 # 모든 파일이 조건 충족
}

# 파일 및 디렉터리 검사
check_passed=true
files_to_check=('/etc/inetd.conf' '/etc/xinetd.conf')
directories_to_check=('/etc/xinetd.d')

for file_path in "${files_to_check[@]}"; do
    if ! check_file_ownership_and_permissions "$file_path"; then
        현황+=("$file_path 파일의 소유자가 root가 아니거나 권한이 600 미만입니다.")
        check_passed=false
    fi
done

for directory_path in "${directories_to_check[@]}"; do
    if ! check_directory_files_ownership_and_permissions "$directory_path"; then
        현황+=("$directory_path 디렉터리 내 파일의 소유자가 root가 아니거나 권한이 600 미만입니다.")
        check_passed=false
    fi
done

# 검사 결과에 따라 진단 결과 업데이트
if $check_passed; then
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
for item in "${현황[@]}"; do
    echo "현황: $item"
done
