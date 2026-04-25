#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-60"
riskLevel="중"
diagnosisItem="ssh 원격접속 허용"
service="Remote Access Management"
diagnosisResult=""
status=""

# SSH 서비스 상태 확인
if systemctl is-active --quiet ssh; then
    ssh_status="활성화"
else
    ssh_status="비활성화"
fi

# Telnet 서비스 상태 확인
if pgrep -f telnetd > /dev/null; then
    telnet_status="활성화"
else
    telnet_status="비활성화"
fi

# FTP 서비스 상태 확인
if pgrep -f ftpd > /dev/null; then
    ftp_status="활성화"
else
    ftp_status="비활성화"
fi

# 전체 보안 상태 결정
if [ "$ssh_status" == "활성화" ] && [ "$telnet_status" == "비활성화" ] && [ "$ftp_status" == "비활성화" ]; then
    diagnosisResult="양호"
    status="양호"
else
    diagnosisResult="취약"
    status="취약"
fi

# Write the results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output the results

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
