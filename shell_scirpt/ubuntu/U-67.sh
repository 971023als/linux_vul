#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-67"
riskLevel="중"
diagnosisItem="SNMP 서비스 Community String의 복잡성 설정"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: SNMP Community String이 적절히 설정되어 있습니다.
[취약]: SNMP Community String이 취약(public 또는 private)으로 설정되어 있습니다.
EOF

# SNMP 서비스 실행 여부 확인
if ! ps -ef | grep -i "snmp" | grep -v "grep" > /dev/null; then
    diagnosisResult="SNMP 서비스를 사용하지 않고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
else
    # snmpd.conf 파일 검색
    snmpdconf_files=$(find / -name snmpd.conf -type f 2>/dev/null)
    weak_string_found=false

    if [[ -z "$snmpdconf_files" ]]; then
        diagnosisResult="SNMP 서비스를 사용하고 있으나, Community String을 설정하는 파일이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        for file_path in $snmpdconf_files; do
            if grep -Eiq "\b(public|private)\b" "$file_path"; then
                weak_string_found=true
                diagnosisResult="SNMP Community String이 취약(public 또는 private)으로 설정되어 있습니다. 파일: $file_path"
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                break
            fi
        done
    fi

    if ! $weak_string_found && [[ -n "$snmpdconf_files" ]]; then
        diagnosisResult="SNMP Community String이 적절히 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
