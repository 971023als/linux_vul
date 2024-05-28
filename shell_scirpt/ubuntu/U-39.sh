#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-39"
riskLevel="상"
diagnosisItem="웹서비스 링크 사용금지"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다.
[취약]: 웹서비스 설정 파일에 심볼릭 링크 사용을 제한하지 않는 설정이 포함되어 있습니다.
EOF

webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")
found_vulnerability=false

for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name "$conf_file" -type f 2>/dev/null)
    for file_path in $find_output; do
        if [[ -n "$file_path" ]]; then
            content=$(cat "$file_path")
            if [[ "$content" == *"Options FollowSymLinks"* && "$content" != *"Options -FollowSymLinks"* ]]; then
                found_vulnerability=true
                diagnosisResult="$file_path 파일에 심볼릭 링크 사용을 제한하지 않는 설정이 포함되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    done
done

if [ "$found_vulnerability" = false ]; then
    diagnosisResult="웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
