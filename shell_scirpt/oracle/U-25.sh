#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-25"
riskLevel="상"
diagnosisItem="NFS 접근 통제"
solution="불필요한 NFS 서비스를 사용하지 않거나, 사용 시 everyone 공유 제한"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: NFS 접근 통제 설정에 문제가 없습니다.
[취약]: NFS 접근 통제 설정에 문제가 있습니다.
EOF

# Check for NFS service running
if ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd'; then
    if [ -f "/etc/exports" ]; then
        # Analyze /etc/exports file
        if grep -qE '\*' "/etc/exports"; then
            diagnosisResult="/etc/exports 파일에 '*' 설정이 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
        if grep -qE 'insecure' "/etc/exports"; then
            diagnosisResult="/etc/exports 파일에 'insecure' 옵션이 설정되어 있습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
        if ! grep -qE 'root_squash|all_squash' "/etc/exports"; then
            diagnosisResult="/etc/exports 파일에 'root_squash' 또는 'all_squash' 옵션이 설정되어 있지 않습니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    else
        diagnosisResult="NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="NFS 서비스가 실행 중이지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Default diagnosis result if no issues found
if [ -z "$diagnosisResult" ]; then
    diagnosisResult="NFS 접근 통제 설정에 문제가 없습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
