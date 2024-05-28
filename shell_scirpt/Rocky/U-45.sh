#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-45"
riskLevel="하"
diagnosisItem="root 계정 su 제한"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

pam_su_path="/etc/pam.d/su"
result="양호"

if [ -f "$pam_su_path" ]; then
    pam_contents=$(cat "$pam_su_path")
    if echo "$pam_contents" | grep -q "pam_rootok.so"; then
        if ! echo "$pam_contents" | grep -q "pam_wheel.so" || ! echo "$pam_contents" | grep -q "auth required pam_wheel.so use_uid"; then
            result="취약"
            status="/etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다."
            echo "WARN: $status"
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
        fi
    else
        result="취약"
        status="/etc/pam.d/su 파일에서 pam_rootok.so 모듈이 누락되었습니다."
        echo "WARN: $status"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    fi
else
    result="취약"
    status="/etc/pam.d/su 파일이 존재하지 않습니다."
    echo "WARN: $status"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
fi

if [ "$result" = "양호" ]; then
    status="/etc/pam.d/su 파일에 대한 설정이 적절하게 구성되어 있습니다."
    echo "OK: $status"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
