#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-11"
위험도="상"
진단항목="/etc/syslog.conf 파일 소유자 및 권한 설정"
대응방안="/etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우"
현황=""
진단결과="파일 없음"

syslog_conf_files=("/etc/rsyslog.conf" "/etc/syslog.conf" "/etc/syslog-ng.conf")
file_exists_count=0
compliant_files_count=0

TMP1=$(basename "$0").log
> $TMP1

for file_path in "${syslog_conf_files[@]}"; do
    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        mode=$(stat -c "%a" "$file_path")
        owner_name=$(stat -c "%U" "$file_path")

        if [[ "$owner_name" == "root" || "$owner_name" == "bin" || "$owner_name" == "sys" ]] && [ "$mode" -le 640 ]; then
            ((compliant_files_count++))
            현황+="$file_path 파일의 소유자가 $owner_name이고, 권한이 $mode입니다. "
        else
            현황+="$file_path 파일의 소유자나 권한이 기준에 부합하지 않습니다. "
        fi
    fi
done

if [ "$file_exists_count" -gt 0 ]; then
    if [ "$compliant_files_count" -eq "$file_exists_count" ]; then
        진단결과="양호"
    else
        진단결과="취약"
    fi
else
    진단결과="파일 없음"
    현황="설정 파일을 찾을 수 없습니다."
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
