#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-46"
riskLevel="중"
diagnosisItem="패스워드 최소 길이 설정"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

files_to_check=(
    "/etc/login.defs:PASS_MIN_LEN"
    "/etc/pam.d/system-auth:minlen"
    "/etc/pam.d/password-auth:minlen"
    "/etc/security/pwquality.conf:minlen"
)

file_exists_count=0
minlen_file_exists_count=0
no_settings_in_minlen_file=0

for item in "${files_to_check[@]}"; do
    IFS=: read -r file_path setting_key <<< "$item"
    if [ -f "$file_path" ]; then
        file_exists_count=$((file_exists_count + 1))
        if grep -iq "$setting_key" "$file_path"; then
            minlen_file_exists_count=$((minlen_file_exists_count + 1))
            min_length=$(grep -i "$setting_key" "$file_path" | grep -v '^#' | grep -o '[0-9]*' | head -1)
            if [ -n "$min_length" ] && [ "$min_length" -lt 8 ]; then
                diagnosisResult="$file_path 파일에 $setting_key 가 8 미만으로 설정되어 있습니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            elif [ -z "$min_length" ]; then
                no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
            fi
        else
            no_settings_in_minlen_file=$((no_settings_in_minlen_file + 1))
        fi
    fi
done

if [ "$file_exists_count" -eq 0 ]; then
    diagnosisResult="패스워드 최소 길이를 설정하는 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ "$minlen_file_exists_count" -eq "$no_settings_in_minlen_file" ]; then
    diagnosisResult="패스워드 최소 길이를 설정한 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

if [ "$status" != "취약" ]; then
    diagnosisResult="패스워드 최소 길이가 적절하게 설정되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
