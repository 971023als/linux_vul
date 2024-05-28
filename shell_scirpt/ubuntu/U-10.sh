#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-10"
위험도="상"
진단항목="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
대응방안="/etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 미만인 경우"
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

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
    check_file_ownership_and_permissions "$file_path"
    result=$?
    if [ $result -eq 1 ]; then
        현황+="$file_path 파일이 없습니다. "
        check_passed=false
    elif [ $result -eq 2 ]; then
        현황+="$file_path 파일의 소유자가 root가 아니거나 권한이 600 미만입니다. "
        check_passed=false
    fi
done

for directory_path in "${directories_to_check[@]}"; do
    check_directory_files_ownership_and_permissions "$directory_path"
    result=$?
    if [ $result -eq 1 ]; then
        현황+="$directory_path 디렉터리가 없습니다. "
        check_passed=false
    elif [ $result -eq 2 ]; then
        현황+="$directory_path 디렉터리 내 파일의 소유자가 root가 아니거나 권한이 600 미만입니다. "
        check_passed=false
    fi
done

# 검사 결과에 따라 진단 결과 업데이트
if $check_passed; then
    진단결과="양호"
else
    진단결과="취약"
fi

# 결과를 로그 파일에 기록
echo "현황: $현황" >> $TMP1

# CSV 파일에 결과 추가
echo "$분류,$코드,$위험도,$진단항목,$대응방안,$진단결과,$현황" >> $OUTPUT_CSV

# 로그 파일 출력
cat $TMP1

# CSV 파일 출력
echo ; echo
cat $OUTPUT_CSV
