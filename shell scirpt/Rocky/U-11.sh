#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-11"
위험도="상"
진단_항목="/etc/syslog.conf 파일 소유자 및 권한 설정"
대응방안="/etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우"
현황=()
진단_결과="파일 없음"

syslog_conf_files=("/etc/rsyslog.conf" "/etc/syslog.conf" "/etc/syslog-ng.conf")
file_exists_count=0
compliant_files_count=0

for file_path in "${syslog_conf_files[@]}"; do
    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        mode=$(stat -c "%a" "$file_path")
        owner_name=$(stat -c "%U" "$file_path")

        if [[ "$owner_name" == "root" || "$owner_name" == "bin" || "$owner_name" == "sys" ]] && [ "$mode" -le 640 ]; then
            ((compliant_files_count++))
            현황+=("$file_path 파일의 소유자가 $owner_name이고, 권한이 $mode입니다.")
        else
            현황+=("$file_path 파일의 소유자나 권한이 기준에 부합하지 않습니다.")
        fi
    fi
done

if [ "$file_exists_count" -gt 0 ]; then
    if [ "$compliant_files_count" -eq "$file_exists_count" ]; then
        진단_결과="양호"
    else
        진단_결과="취약"
    fi
else
    진단_결과="파일 없음"
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
