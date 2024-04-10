#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-18"
위험도="상"
진단_항목="접속 IP 및 포트 제한"
대응방안="특정 호스트에 대한 IP 주소 및 포트 제한 설정"
현황=()

hosts_deny_path='/etc/hosts.deny'
hosts_allow_path='/etc/hosts.allow'

# 파일 존재 및 내용 검사 함수
check_file_exists_and_content() {
    local file_path=$1
    local search_string=$2
    if [ -f "$file_path" ]; then
        if grep -q -i "^$search_string" "$file_path"; then
            return 0 # 검색 문자열이 파일에 있음
        fi
    fi
    return 1 # 파일이 없거나 검색 문자열이 파일에 없음
}

# /etc/hosts.deny 검사
if ! check_file_exists_and_content "$hosts_deny_path" "ALL: ALL"; then
    진단_결과="취약"
    현황+=("$hosts_deny_path 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다.")
else
    # /etc/hosts.allow 검사
    if check_file_exists_and_content "$hosts_allow_path" "ALL: ALL"; then
        진단_결과="취약"
        현황+=("$hosts_allow_path 파일에 'ALL: ALL' 설정이 있습니다.")
    else
        진단_결과="양호"
        현황+=("적절한 IP 및 포트 제한 설정이 확인되었습니다.")
    fi
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
