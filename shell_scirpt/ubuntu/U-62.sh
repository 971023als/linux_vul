#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-62"
riskLevel="중"
diagnosisItem="ftp 계정 shell 제한"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: ftp 계정에 /bin/false 쉘이 부여되어 있습니다.
[취약]: ftp 계정에 /bin/false 쉘이 부여되어 있지 않습니다.
EOF

# /etc/passwd에서 ftp 계정 확인
if grep -q "^ftp:" /etc/passwd; then
    ftp_shell=$(grep "^ftp:" /etc/passwd | cut -d':' -f7)
    if [ "$ftp_shell" = "/bin/false" ]; then
        diagnosisResult="ftp 계정에 /bin/false 쉘이 부여되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ftp 계정에 /bin/false 쉘이 부여되어 있지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    diagnosisResult="ftp 계정이 시스템에 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
