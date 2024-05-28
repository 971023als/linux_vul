#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-06"
riskLevel="상"
diagnosisItem="파일 및 디렉터리 소유자 설정"
diagnosisResult= ""
status=""

no_owner_files=()

# Function: Find files and directories without owners
check_no_owner_files() {
    while IFS= read -r -d '' file; do
        # Check if the file owner and group exist, if not add to the array
        if ! getent passwd "$(stat -c "%u" "$file")" > /dev/null || \
           ! getent group "$(stat -c "%g" "$file")" > /dev/null; then
            no_owner_files+=("$file")
        fi
    done < <(find / -nouser -nogroup -print0 2>/dev/null)
}

check_no_owner_files

# Set diagnosis result and status
if [ ${#no_owner_files[@]} -gt 0 ]; then
    diagnosisResult="취약"
    status="소유자가 존재하지 않는 파일 및 디렉터리:\n$(printf '%s\n' "${no_owner_files[@]}")"
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

# Print the final CSV output
cat $OUTPUT_CSV
