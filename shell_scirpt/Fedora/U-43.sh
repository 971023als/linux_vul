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
cat $OUTPUT_CSV
