#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="시스템 설정"
code="U-20"
riskLevel="상"
diagnosisItem="Anonymous FTP 비활성화"
solution="[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우\n[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우
[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우
EOF

# Check if the ftp user exists in /etc/passwd
if grep -q "^ftp:" /etc/passwd; then
    diagnosisResult="FTP 계정이 /etc/passwd 파일에 있습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="FTP 계정이 /etc/passwd 파일에 없습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
