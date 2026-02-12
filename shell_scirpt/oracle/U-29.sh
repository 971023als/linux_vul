#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-29"
riskLevel="상"
diagnosisItem="tftp, talk 서비스 비활성화"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: tftp, talk, ntalk 서비스가 모두 비활성화되어 있습니다.
[취약]: tftp, talk, ntalk 서비스가 활성화되어 있습니다.
EOF

services=("tftp" "talk" "ntalk")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"
service_found=false

# Check for services in /etc/xinetd.d directory
if [ -d "$xinetd_dir" ]; then
    for service in "${services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -q 'disable\s*=\s*yes' "$service_path"; then
                diagnosisResult="$service 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                cat $TMP1
                echo ; echo
                exit 0
            fi
        fi
    done
fi

# Check for services in /etc/inetd.conf file
if [ -f "$inetd_conf" ]; then
    for service in "${services[@]}"; do
        if grep -E "^$service\s" "$inetd_conf" &> /dev/null; then
            diagnosisResult="$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            cat $TMP1
            echo ; echo
            exit 0
        fi
    done
fi

# Determine final diagnosis result
if $service_found; then
    diagnosisResult="tftp, talk, ntalk 서비스가 활성화되어 있습니다."
    status="취약"
else
    diagnosisResult="tftp, talk, ntalk 서비스가 모두 비활성화되어 있습니다."
    status="양호"
fi

# Write final results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
