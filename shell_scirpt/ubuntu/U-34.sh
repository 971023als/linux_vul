#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-34"
riskLevel="상"
diagnosisItem="DNS Zone Transfer 설정"
solution="Zone Transfer를 허가된 사용자에게만 허용"
diagnosisResult=""
status=""
named_conf_path="/etc/named.conf"
현황=()

TMP1=$(basename "$0").log
> $TMP1

# Check if DNS service is running
if ps -ef | grep -i 'named' | grep -v 'grep' &> /dev/null; then
    dns_service_running=true
else
    dns_service_running=false
fi

if $dns_service_running; then
    if [ -f "$named_conf_path" ]; then
        if grep -q "allow-transfer { any; }" "$named_conf_path"; then
            diagnosisResult="/etc/named.conf 파일에 allow-transfer { any; } 설정이 있습니다."
            status="취약"
        else
            diagnosisResult="DNS Zone Transfer가 허가된 사용자에게만 허용되어 있습니다."
            status="양호"
        fi
    else
        diagnosisResult="/etc/named.conf 파일이 존재하지 않습니다. DNS 서비스 미사용 가능성."
        status="양호"
    fi
else
    diagnosisResult="DNS 서비스가 실행 중이지 않습니다."
    status="양호"
fi

현황+=("$diagnosisResult")

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output log and CSV file contents
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
