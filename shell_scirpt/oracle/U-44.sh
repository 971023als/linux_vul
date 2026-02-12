#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-44"
riskLevel="중"
diagnosisItem="root 이외의 UID가 '0' 금지"
service="Account Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# /etc/passwd 파일에서 UID가 '0'이고 사용자 이름이 'root'가 아닌 계정 검사
vulnerable=false
while IFS=: read -r username _ userid _; do
    if [ "$userid" == "0" ] && [ "$username" != "root" ]; then
        vulnerable=true
        diagnosisResult="root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: $username"
        status="취약"
        echo "WARN: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        break
    fi
done < /etc/passwd

if [ "$vulnerable" = false ]; then
    diagnosisResult="root 계정 외에 UID 0을 갖는 계정이 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
