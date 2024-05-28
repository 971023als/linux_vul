#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-55"
riskLevel="하"
diagnosisItem="hosts.lpd 파일 소유자 및 권한 설정"
service="File and Directory Management"
diagnosisResult="양호"
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

hosts_lpd_path="/etc/hosts.lpd"

if [ -e "$hosts_lpd_path" ]; then
    file_owner=$(stat -c "%u" "$hosts_lpd_path")
    file_mode=$(stat -c "%a" "$hosts_lpd_path")

    if [ "$file_owner" != "0" ] || [ "$file_mode" != "600" ]; then
        diagnosisResult="/etc/hosts.lpd 파일 상태: "
        status="취약"
        if [ "$file_owner" != "0" ]; then
            diagnosisResult+="root 소유가 아님, "
        else
            diagnosisResult+="소유자 상태는 양호함, "
        fi
        if [ "$file_mode" != "600" ]; then
            diagnosisResult+="권한이 600이 아님"
        else
            diagnosisResult+="권한 상태는 양호함"
        fi
        echo "WARN: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="hosts.lpd 파일 소유자 및 권한이 적절하게 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/hosts.lpd 파일이 존재하지 않으므로 검사 대상이 아닙니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
