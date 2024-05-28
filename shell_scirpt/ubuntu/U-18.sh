#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-18"
riskLevel="상"
diagnosisItem="접속 IP 및 포트 제한"
solution="특정 호스트에 대한 IP 주소 및 포트 제한 설정"
diagnosisResult=""
status=""

# Initial log file
TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 적절한 IP 및 포트 제한 설정이 확인된 경우
[취약]: 'ALL: ALL' 설정이 없거나 부적절하게 설정된 경우
EOF

hosts_deny_path='/etc/hosts.deny'
hosts_allow_path='/etc/hosts.allow'

# Check if file exists and contains specific string
check_file_exists_and_content() {
    local file_path=$1
    local search_string=$2
    if [ -f "$file_path" ]; then
        if grep -q -i "^$search_string" "$file_path"; then
            return 0 # Search string is present in the file
        fi
    fi
    return 1 # File does not exist or search string is not present in the file
}

# Check /etc/hosts.deny
if ! check_file_exists_and_content "$hosts_deny_path" "ALL: ALL"; then
    diagnosisResult="$hosts_deny_path 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    # Check /etc/hosts.allow
    if check_file_exists_and_content "$hosts_allow_path" "ALL: ALL"; then
        diagnosisResult="$hosts_allow_path 파일에 'ALL: ALL' 설정이 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
    else
        diagnosisResult="적절한 IP 및 포트 제한 설정이 확인되었습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
