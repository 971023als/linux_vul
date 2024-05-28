#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-12"
위험도="상"
진단항목="/etc/services 파일 소유자 및 권한 설정"
대응방안="/etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우"
services_file='/etc/services'
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

# /etc/services 파일 존재 여부 확인
if [ -e "$services_file" ]; then
    # 파일 권한 및 소유자 확인
    mode=$(stat -c "%a" "$services_file")
    owner_name=$(stat -c "%U" "$services_file")

    # 소유자가 root, bin 또는 sys이고 권한이 644 이하인지 확인
    if [[ "$owner_name" == "root" || "$owner_name" == "bin" || "$owner_name" == "sys" ]] && [ "$mode" -le 644 ]; then
        진단결과="양호"
        현황="$services_file 파일의 소유자가 $owner_name이고, 권한이 $mode입니다."
    else
        진단결과="취약"
        현황="$services_file 파일의 소유자나 권한이 기준에 부합하지 않습니다."
    fi
else
    진단결과="정보 없음"
    현황="$services_file 파일이 없습니다."
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
