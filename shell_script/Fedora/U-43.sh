#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,logFile,result,status" > $OUTPUT_CSV
fi

# Initial Values
category="로그 관리"
code="U-43"
riskLevel="상"
diagnosisItem="로그의 정기적 검토 및 보고"
service="Log Management"
status="양호"

# Log file list
declare -A log_files=(
    ["UTMP"]="/var/log/utmp"
    ["WTMP"]="/var/log/wtmp"
    ["BTMP"]="/var/log/btmp"
    ["SULOG"]="/var/log/sulog"
    ["XFERLOG"]="/var/log/xferlog"
)

# Log file existence check
for log_name in "${!log_files[@]}"; do
    log_path="${log_files[$log_name]}"
    if [ -f "$log_path" ]; then
        result="존재함"
    else
        result="존재하지 않음"
    fi
    # Write results to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$log_name,$result,$status" >> $OUTPUT_CSV
done

# Output CSV

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
