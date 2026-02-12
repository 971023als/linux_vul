#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-07"
riskLevel="상"
diagnosisItem="/etc/passwd 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

passwd_file='/etc/passwd'
현황=()

# Check if /etc/passwd file exists
if [ -e "$passwd_file" ]; then
    # Get file permissions and owner
    mode=$(stat -c "%a" "$passwd_file")
    owner_uid=$(stat -c "%u" "$passwd_file")

    # Check if the owner is root
    if [ "$owner_uid" -eq 0 ]; then
        # Check if permissions are 644 or less
        if [ "$mode" -le 644 ]; then
            diagnosisResult="양호"
            status="/etc/passwd 파일의 소유자가 root이고, 권한이 $mode입니다."
        else
            diagnosisResult="취약"
            status="/etc/passwd 파일의 권한이 $mode로 설정되어 있어 취약합니다."
        fi
    else
        diagnosisResult="취약"
        status="/etc/passwd 파일의 소유자가 root가 아닙니다."
    fi
else
    diagnosisResult="N/A"
    status="/etc/passwd 파일이 없습니다."
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

# Print the final CSV output
cat $OUTPUT_CSV
