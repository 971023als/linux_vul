#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-05"
riskLevel="상"
diagnosisItem="root홈, 패스 디렉터리 권한 및 패스 설정"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Variables
global_files=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

user_files=(
    ".profile"
    ".cshrc"
    ".login"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)

현황=()

# Check global configuration files
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file"; then
            현황+=("$file 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")
        fi
    fi
done

# Check user home directory configuration files
while IFS=: read -r username _ _ _ _ homedir _; do
    for user_file in "${user_files[@]}"; do
        file_path="$homedir/$user_file"
        if [ -f "$file_path" ]; then
            if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file_path"; then
                현황+=("$file_path 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")
            fi
        fi
    done
done < /etc/passwd

# Set diagnosis result
if [ ${#현황[@]} -eq 0 ]; then
    diagnosisResult="양호"
    status="설정 파일에 문제가 없습니다."
else
    diagnosisResult="취약"
    status=$(IFS=$'\n'; echo "${현황[*]}")
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Print the final CSV output
cat $OUTPUT_CSV
