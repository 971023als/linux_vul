#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-32"
riskLevel="상"
diagnosisItem="일반사용자의 Sendmail 실행 방지"
solution="SMTP 서비스 미사용 또는 일반 사용자의 Sendmail 실행 방지 설정"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

restriction_set=false
현황=()

# Find sendmail.cf files and check for restrictqrun option
find / -name 'sendmail.cf' -type f 2>/dev/null | while read -r file_path; do
    if grep -q 'restrictqrun' "$file_path" && ! grep -q '^#' "$file_path"; then
        현황+=("$file_path 파일에 restrictqrun 옵션이 설정되어 있습니다.")
        restriction_set=true
        break # Stop checking further if one valid file is found
    fi
done

# Determine the diagnosis result
if $restriction_set; then
    diagnosisResult="모든 sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정되어 있습니다."
    status="양호"
    if [ ${#현황[@]} -eq 0 ]; then
        현황+=("모든 sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정되어 있습니다.")
    fi
else
    diagnosisResult="sendmail.cf 파일 중 restrictqrun 옵션이 설정되어 있지 않은 파일이 있습니다."
    status="취약"
    if [ ${#현황[@]} -eq 0 ]; then
        현황+=("sendmail.cf 파일 중 restrictqrun 옵션이 설정되어 있지 않은 파일이 있습니다.")
    fi
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output log and CSV file contents
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
