#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-19"
riskLevel="상"
diagnosisItem="Finger 서비스 비활성화"
solution="Finger 서비스가 비활성화 되어 있는 경우"
diagnosisResult=""
status=""

# Initial log file
TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Finger 서비스가 비활성화되어 있거나 실행 중이지 않은 경우
[취약]: Finger 서비스가 활성화되어 있거나 실행 중인 경우
EOF

# Check if /etc/services contains Finger service definition
if grep -iq "^finger.*tcp" /etc/services; then
    diagnosisResult="/etc/services에 Finger 서비스 포트가 정의되어 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    if [ ! -f "/etc/services" ]; then
        diagnosisResult="/etc/services 파일을 찾을 수 없습니다."
        status="정보 없음"
        echo "INFO: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
fi

# Check if Finger process is running
if ps -ef | grep -iq "finger"; then
    diagnosisResult="Finger 서비스 프로세스가 실행 중입니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Final check if diagnosisResult is empty, meaning everything is fine
if [ -z "$diagnosisResult" ]; then
    diagnosisResult="Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
