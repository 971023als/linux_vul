#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-64"
riskLevel="중"
diagnosisItem="ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)"
service="Account Management"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: FTP 서비스 root 계정 접근이 제한되어 있습니다.
[취약]: FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다.
EOF

# 검사할 ftpusers 파일 및 설정 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/ftpd/ftpusers" "/etc/proftpd.conf"
    "/etc/vsftp/ftpusers" "/etc/vsftp/user_list" "/etc/vsftpd.ftpusers"
    "/etc/vsftpd.user_list"
)

# 실행 중인 FTP 서비스 확인
if ! pgrep -f -e ftpd && ! pgrep -f -e vsftpd && ! pgrep -f -e proftpd; then
    status="FTP 서비스가 비활성화 되어 있습니다."
    result="양호"
else
    root_access_restricted=false

    for ftpusers_file in "${ftpusers_files[@]}"; do
        if [ -f "$ftpusers_file" ]; then
            # proftpd.conf의 경우 'RootLogin on' 설정 확인
            if [[ "$ftpusers_file" == *proftpd.conf* ]] && grep -q "RootLogin on" "$ftpusers_file"; then
                result="취약"
                status="$ftpusers_file 파일에 'RootLogin on' 설정이 있습니다."
                echo "WARN: $status" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
                break
            # 다른 ftpusers 파일의 경우 'root' 존재 확인
            elif grep -q "^root$" "$ftpusers_file"; then
                root_access_restricted=true
            fi
        fi
    done

    if $root_access_restricted; then
        result="양호"
        status="FTP 서비스 root 계정 접근이 제한되어 있습니다."
        echo "OK: $status" >> $TMP1
    else
        result="취약"
        status="FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다."
        echo "WARN: $status" >> $TMP1
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
    fi
fi

# Write final results to CSV if no vulnerabilities found
if [ "$result" = "양호" ]; then
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$result,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
