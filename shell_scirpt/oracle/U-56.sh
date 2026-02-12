#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉토리 관리"
code="U-56"
riskLevel="중"
diagnosisItem="UMASK 설정 관리"
service="File and Directory Management"
diagnosisResult="양호"
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Define files to check
files_to_check=(
    "/etc/profile"
    "/etc/bash.bashrc"
    "/etc/csh.login"
    "/etc/csh.cshrc"
    /home/*/.profile
    /home/*/.bashrc
    /home/*/.cshrc
    /home/*/.login
)

checked_files=0

# Check umask values in each file
for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        checked_files=$((checked_files + 1))
        if grep -q "umask" "$file_path" && ! grep -E "^#" "$file_path" | grep -q "umask"; then
            umask_values=$(grep "umask" "$file_path" | awk '{print $2}' | tr -d '`')
            for value in $umask_values; do
                if [ $(("$value")) -lt 22 ]; then
                    diagnosisResult="$file_path 파일에서 UMASK 값 ($value)이 022 이상으로 설정되지 않았습니다."
                    status="취약"
                    echo "WARN: $diagnosisResult"
                    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                fi
            done
        fi
    fi
done

if [ "$checked_files" -eq 0 ]; then
    diagnosisResult="검사할 파일이 없습니다."
    status="정보 없음"
    echo "INFO: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
elif [ "$status" = "양호" ]; then
    diagnosisResult="모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
