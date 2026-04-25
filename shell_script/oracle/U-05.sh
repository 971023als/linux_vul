#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-05"
riskLevel="상"
diagnosisItem="root홈, 패스 디렉터리 권한 및 패스 설정"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Variables
global_files=(
    "/etc/profile"
    "/etc/.login"
    "/etc/csh.cshrc"
    "/etc/csh.login"
    "/etc/environment"
)

user_files=(
    ".profile"
    ".cshrc"
    ".login"
    ".kshrc"
    ".bash_profile"
    ".bashrc"
    ".bash_login"
)

_status_list=()

# Check global configuration files
for file in "${global_files[@]}"; do
    if [ -f "$file" ]; then
        if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file"; then
            _status_list+=("$file 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.")
        fi
    fi
done

# Check user home directory configuration files
while IFS=: read -r username _ _ _ _ homedir _; do
    for user_file in "${user_files[@]}"; do
        file_path="$homedir/$user_file"
        if [ -f "$file_path" ]; then
            if grep -Eq '\b\.\b|(^|:)\.(:|$)' "$file_path"; then
                _status_list+=("$file_path 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.")
            fi
        fi
    done
done < /etc/passwd

# Set diagnosis result
if [ ${#_status_list[@]} -eq 0 ]; then
    diagnosisResult="양호"
    status="설정 파일에 문제가 없습니다."
else
    diagnosisResult="취약"
    status=$(IFS=$'\n'; echo "${_status_list[*]}")
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

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
