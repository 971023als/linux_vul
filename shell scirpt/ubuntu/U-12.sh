#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-12"
위험도="상"
진단_항목="/etc/services 파일 소유자 및 권한 설정"
대응방안="/etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우"
services_file='/etc/services'
현황=()

# /etc/services 파일 존재 여부 확인
if [ -e "$services_file" ]; then
    # 파일 권한 및 소유자 확인
    mode=$(stat -c "%a" "$services_file")
    owner_name=$(stat -c "%U" "$services_file")

    # 소유자가 root, bin 또는 sys이고 권한이 644 이하인지 확인
    if [[ "$owner_name" == "root" || "$owner_name" == "bin" || "$owner_name" == "sys" ]] && [ "$mode" -le 644 ]; then
        진단_결과="양호"
        현황+=("$services_file 파일의 소유자가 $owner_name이고, 권한이 $mode입니다.")
    else
        진단_결과="취약"
        현황+=("$services_file 파일의 소유자나 권한이 기준에 부합하지 않습니다.")
    fi
else
    진단_결과="N/A"
    현황+=("$services_file 파일이 없습니다.")
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
