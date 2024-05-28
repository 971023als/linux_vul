#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-09"
위험도="상"
진단항목="/etc/hosts 파일 소유자 및 권한 설정"
대응방안="/etc/hosts 파일의 소유자가 root이고, 권한이 600 이하인 경우"
hosts_file='/etc/hosts'
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

# /etc/hosts 파일 존재 여부 확인
if [ -e "$hosts_file" ]; then
    # 파일 권한 및 소유자 확인
    mode=$(stat -c "%a" "$hosts_file")
    owner_uid=$(stat -c "%u" "$hosts_file")

    # 소유자가 root이고 권한이 600 이하인지 확인
    if [ "$owner_uid" -eq 0 ]; then
        if [ "$mode" -le 600 ]; then
            진단결과="양호"
            현황="/etc/hosts 파일의 소유자가 root이고, 권한이 $mode입니다."
        else
            진단결과="취약"
            현황="/etc/hosts 파일의 권한이 $mode로 설정되어 있어 취약합니다."
        fi
    else
        진단결과="취약"
        현황="/etc/hosts 파일의 소유자가 root가 아닙니다."
    fi
else
    진단결과="정보 없음"
    현황="/etc/hosts 파일이 없습니다."
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
