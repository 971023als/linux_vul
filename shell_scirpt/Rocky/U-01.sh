#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status,details" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-01"
riskLevel="상"
diagnosisItem="root 계정 원격접속 제한"
diagnosisResult="양호"
status=""
details=""

# Function to write results to CSV
write_to_csv() {
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status,$details" >> $OUTPUT_CSV
}

# Telnet 서비스 검사
telnet_status=$(grep -E "telnet\s+\d+/tcp" /etc/services)
if [[ $telnet_status ]]; then
    diagnosisResult="취약"
    status="Telnet 서비스 포트가 활성화되어 있습니다."
    details="Telnet 서비스 포트가 활성화되어 있습니다."
    write_to_csv
else
    status="Telnet 서비스 포트가 비활성화되어 있습니다."
    details="Telnet 서비스 포트가 비활성화되어 있습니다."
    write_to_csv
fi

# SSH 서비스 검사
root_login_restricted=true
sshd_configs=$(find /etc/ssh -name 'sshd_config')

for sshd_config in $sshd_configs; do
    if grep -Eq 'PermitRootLogin\s+(yes|without-password)' "$sshd_config" && ! grep -Eq 'PermitRootLogin\s+(no|prohibit-password|forced-commands-only)' "$sshd_config"; then
        root_login_restricted=false
        break
    fi
done

if [[ $root_login_restricted == false ]]; then
    diagnosisResult="취약"
    status="SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다."
    details="SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다."
else
    status="SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다."
    details="SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다."
fi

write_to_csv

# Print the final CSV output
cat $OUTPUT_CSV
