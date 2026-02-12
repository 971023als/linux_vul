#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-31"
riskLevel="상"
diagnosisItem="스팸 메일 릴레이 제한"
solution="SMTP 서비스 릴레이 제한 설정"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

search_directory='/etc/mail/'
vulnerable_found=false
현황=()

# Search for sendmail.cf files and analyze their contents
find "$search_directory" -name 'sendmail.cf' -type f | while read -r file_path; do
    if [ -f "$file_path" ]; then
        if grep -qE 'R\$\*' "$file_path" || grep -qEi 'Relaying denied' "$file_path"; then
            현황+=("$file_path 파일에 릴레이 제한이 적절히 설정되어 있습니다.")
        else
            vulnerable_found=true
            현황+=("$file_path 파일에 릴레이 제한 설정이 없습니다.")
        fi
    fi
done

# Determine the diagnosis result
if $vulnerable_found; then
    diagnosisResult="릴레이 제한 설정이 없습니다."
    status="취약"
else
    if [ ${#현황[@]} -eq 0 ]; then
        diagnosisResult="sendmail.cf 파일을 찾을 수 없거나 접근할 수 없습니다."
        status="양호"
    else
        diagnosisResult="릴레이 제한이 적절히 설정되어 있습니다."
        status="양호"
    fi
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output log and CSV file contents
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
