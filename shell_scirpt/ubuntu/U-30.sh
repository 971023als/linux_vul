#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-30"
riskLevel="상"
diagnosisItem="Sendmail 버전 점검"
solution="Sendmail 버전을 최신 버전으로 유지"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

latest_version="8.17.1"  # 최신 Sendmail 버전 예시

# Check Sendmail version on RPM-based systems
sendmail_version=$(rpm -qa | grep 'sendmail' | grep -oP 'sendmail-\K(\d+\.\d+\.\d+)')

# Determine the diagnosis result
if [[ $sendmail_version ]]; then
    if [[ $sendmail_version == $latest_version* ]]; then
        diagnosisResult="Sendmail 버전이 최신 버전(${latest_version})입니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Sendmail 버전이 최신 버전(${latest_version})이 아닙니다. 현재 버전: ${sendmail_version}"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="Sendmail이 설치되어 있지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
