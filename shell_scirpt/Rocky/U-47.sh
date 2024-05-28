#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-47"
riskLevel="중"
diagnosisItem="패스워드 최대 사용기간 설정"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

login_defs_path="/etc/login.defs"
result="양호"

if [ -f "$login_defs_path" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "PASS_MAX_DAYS" && ! echo "$line" | grep -q "^#"; then
            max_days=$(echo "$line" | awk '{print $2}')
            if [ "$max_days" -gt 90 ]; then
                result="취약"
                diagnosisResult="/etc/login.defs 파일에 패스워드 최대 사용 기간이 90일을 초과하여 $max_days 일로 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
            break
        fi
    done < "$login_defs_path"
else
    result="취약"
    diagnosisResult="/etc/login.defs 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

if [ "$result" = "양호" ]; then
    diagnosisResult="패스워드 최대 사용 기간이 적절하게 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
