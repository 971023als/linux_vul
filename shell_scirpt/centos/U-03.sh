#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-03"
riskLevel="상"
diagnosisItem="계정 잠금 임계값 설정"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Variables
deny_files_checked=false
account_lockout_threshold_set=false
files_to_check=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
)
deny_modules=("pam_tally2.so" "pam_faillock.so")
현황=()

for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        deny_files_checked=true
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | xargs) # Trim
            if [[ ! "$line" =~ ^# && "$line" =~ deny ]]; then
                for deny_module in "${deny_modules[@]}"; do
                    if [[ "$line" =~ $deny_module ]]; then
                        deny_value=$(echo "$line" | grep -oP 'deny=\K\d+')
                        if [[ "$deny_value" -le 10 ]]; then
                            account_lockout_threshold_set=true
                        else
                            현황+=("$file_path에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")
                        fi
                    fi
                done
            fi
        done < "$file_path"
    fi
done

if ! $deny_files_checked; then
    현황+=("계정 잠금 임계값을 설정하는 파일을 찾을 수 없습니다.")
    diagnosisResult="취약"
elif ! $account_lockout_threshold_set; then
    현황+=("적절한 계정 잠금 임계값 설정이 없습니다.")
    diagnosisResult="취약"
else
    현황+=("계정 잠금 임계값이 적절히 설정되었습니다.")
    diagnosisResult="양호"
fi

status=$(IFS=$'\n'; echo "${현황[*]}")

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Print the final CSV output
cat $OUTPUT_CSV
