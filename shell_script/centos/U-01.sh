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

# ==== MD OUTPUT (stdout — shell_runner.sh 가 캡처하여 stdout.txt 저장) ====
_md_code="${code:-${CODE:-U-??}}"
_md_category="${category:-}"
_md_risk="${riskLevel:-${severity:-}}"
_md_item="${diagnosisItem:-${check_item:-진단항목}}"
_md_result="${diagnosisResult:-${result:-}}"
_md_status="${status:-${details:-${service:-}}}"
_md_solution="${solution:-${recommendation:-}}"

cat << __MD_EOF__
# ${_md_code}: ${_md_item}

| 항목 | 내용 |
|------|------|
| 분류 | ${_md_category} |
| 코드 | ${_md_code} |
| 위험도 | ${_md_risk} |
| 진단항목 | ${_md_item} |
| 진단결과 | ${_md_result} |
| 현황 | ${_md_status} |
| 대응방안 | ${_md_solution} |
__MD_EOF__
