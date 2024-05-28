#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-26"
riskLevel="상"
diagnosisItem="automountd 제거"
solution="automountd 서비스 비활성화"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: automountd 서비스가 비활성화되어 있습니다.
[취약]: automountd 서비스가 실행 중입니다.
EOF

# Check if automountd or autofs services are running
if ps -ef | grep -iE '[a]utomount|[a]utofs' &> /dev/null; then
    diagnosisResult="automountd 서비스가 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="automountd 서비스가 비활성화되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
