#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-63"
riskLevel="하"
diagnosisItem="ftpusers 파일 소유자 및 권한 설정"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다.
[취약]: ftpusers 파일의 소유자가 root가 아니거나 권한이 640보다 큰 경우
EOF

# 검사할 ftpusers 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers"
    "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers"
    "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list"
)

file_checked_and_secure=false
vulnerabilities=()

for ftpusers_file in "${ftpusers_files[@]}"; do
    if [ -f "$ftpusers_file" ]; then
        file_checked_and_secure=true
        owner=$(stat -c "%U" "$ftpusers_file")
        permissions=$(stat -c "%a" "$ftpusers_file")

        # 소유자가 root가 아니거나 권한이 640보다 큰 경우
        if [ "$owner" != "root" ] || [ "$permissions" -gt 640 ]; then
            diagnosisResult=""
            status="취약"
            [ "$owner" != "root" ] && vulnerabilities+=("$ftpusers_file 파일의 소유자(owner)가 root가 아닙니다.")
            [ "$permissions" -gt 640 ] && vulnerabilities+=("$ftpusers_file 파일의 권한이 640보다 큽니다.")
        fi
    fi
done

# 파일 검사 후 취약하지 않은 경우 양호로 설정
if [ ${#vulnerabilities[@]} -eq 0 ]; then
    if $file_checked_and_secure; then
        diagnosisResult="모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ftp 접근제어 파일이 없습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
else
    for vulnerability in "${vulnerabilities[@]}"; do
        diagnosisResult="$vulnerability"
        echo "WARN: $diagnosisResult" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done
fi

# Write final results to CSV if no vulnerabilities found
if [ $file_checked_and_secure = true ] && [ ${#vulnerabilities[@]} -eq 0 ]; then
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
