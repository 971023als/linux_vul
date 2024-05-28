#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="패치 관리"
code="U-42"
riskLevel="상"
diagnosisItem="최신 보안패치 및 벤더 권고사항 적용"
service="Patch Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 시스템은 최신 보안 패치를 보유하고 있습니다.
[취약]: 시스템에 보안 패치가 필요합니다.
EOF

# Ubuntu 시스템에서 보안 패치를 확인하는 명령어 실행
output=$(sudo unattended-upgrades --dry-run --debug 2>&1)

# 출력 내용에서 보안 패치 여부를 확인
if [[ $output == *"All upgrades installed"* ]]; then
    diagnosisResult="시스템은 최신 보안 패치를 보유하고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    diagnosisResult="시스템에 보안 패치가 필요합니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
fi

# Write result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Log and output CSV
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
