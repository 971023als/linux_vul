#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-28"
riskLevel="상"
diagnosisItem="NIS, NIS+ 점검"
solution="NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NIS 서비스가 비활성화되어 있습니다.
[취약]: NIS 서비스가 실행 중입니다.
EOF

# Check for NIS related processes
if ps -ef | grep -E '[y]pserv|[y]pbind|[y]pxfrd|[r]pc.yppasswdd|[r]pc.ypupdated' &> /dev/null; then
    diagnosisResult="NIS 서비스가 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="NIS 서비스가 비활성화되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
