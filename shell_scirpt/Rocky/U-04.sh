#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-04"
riskLevel="상"
diagnosisItem="패스워드 파일 보호"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Variables
passwd_file="/etc/passwd"
shadow_file="/etc/shadow"
shadow_used=true  # Assume shadow passwords are used
현황=()

# Check for shadow password usage in /etc/passwd
if [ -f "$passwd_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        IFS=':' read -r -a parts <<< "$line"
        if [ "${#parts[@]}" -gt 1 ] && [ "${parts[1]}" != "x" ]; then
            shadow_used=false
            break
        fi
    done < "$passwd_file"
fi

# Check /etc/shadow file existence and permissions
if $shadow_used && [ -f "$shadow_file" ]; then
    if [ ! -r "$shadow_file" ]; then  # Ensure /etc/shadow is read-only
        현황+=("/etc/shadow 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
        shadow_used=false
    fi
fi

if ! $shadow_used; then
    현황+=("쉐도우 패스워드를 사용하고 있지 않거나 /etc/shadow 파일의 권한 설정이 적절하지 않습니다.")
    diagnosisResult="취약"
else
    현황+=("쉐도우 패스워드를 사용하고 있으며 /etc/shadow 파일의 권한 설정이 적절합니다.")
    diagnosisResult="양호"
fi

status=$(IFS=$'\n'; echo "${현황[*]}")

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Print the final CSV output
cat $OUTPUT_CSV
