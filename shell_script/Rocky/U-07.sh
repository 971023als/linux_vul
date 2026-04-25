#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-07"
riskLevel="상"
diagnosisItem="/etc/passwd 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

passwd_file='/etc/passwd'
_status_list=()

# Check if /etc/passwd file exists
if [ -e "$passwd_file" ]; then
    # Get file permissions and owner
    mode=$(stat -c "%a" "$passwd_file")
    owner_uid=$(stat -c "%u" "$passwd_file")

    # Check if the owner is root
    if [ "$owner_uid" -eq 0 ]; then
        # Check if permissions are 644 or less
        if [ "$mode" -le 644 ]; then
            diagnosisResult="양호"
            status="/etc/passwd 파일의 소유자가 root이고, 권한이 $mode입니다."
        else
            diagnosisResult="취약"
            status="/etc/passwd 파일의 권한이 $mode로 설정되어 있어 취약합니다."
        fi
    else
        diagnosisResult="취약"
        status="/etc/passwd 파일의 소유자가 root가 아닙니다."
    fi
else
    diagnosisResult="N/A"
    status="/etc/passwd 파일이 없습니다."
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

# Print the final CSV output

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
