#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-65"
riskLevel="중"
diagnosisItem="at 서비스 권한 설정"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다.
[취약]: at 명령어 실행 파일이 다른 사용자(other)에 의해 실행 가능하거나, at 접근 제어 파일의 소유자가 root가 아니거나 권한이 640보다 큼
EOF

# at 명령어 실행 파일 권한 확인
permission_issues_found=false

# PATH 내 at 명령어 경로 확인 및 권한 검사
for path in ${PATH//:/ }; do
    if [[ -x "$path/at" ]]; then
        permissions=$(stat -c "%a" "$path/at")
        if [[ "$permissions" =~ .*[2-7]. ]]; then
            diagnosisResult="$path/at 실행 파일이 다른 사용자(other)에 의해 실행이 가능합니다."
            status="취약"
            permission_issues_found=true
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    fi
done

# /etc/at.allow 및 /etc/at.deny 파일 권한 확인
at_access_control_files=("/etc/at.allow" "/etc/at.deny")
for file in "${at_access_control_files[@]}"; do
    if [[ -f "$file" ]]; then
        permissions=$(stat -c "%a" "$file")
        file_owner=$(stat -c "%U" "$file")
        if [[ "$file_owner" != "root" ]] || [[ "$permissions" -gt 640 ]]; then
            diagnosisResult="$file 파일의 소유자가 $file_owner이고, 권한이 ${permissions}입니다."
            status="취약"
            permission_issues_found=true
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    fi
done

# 진단 결과 결정
if ! $permission_issues_found; then
    diagnosisResult="모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
