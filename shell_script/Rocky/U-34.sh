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
_status_list=()

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

_status_list+=("$diagnosisResult")

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

# Output log and CSV file contents
cat $TMP1

echo ; echo


status="${_status_list[*]}"
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
