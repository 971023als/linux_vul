#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="파일 및 디렉터리 관리"
code="U-06"
riskLevel="상"
diagnosisItem="파일 및 디렉터리 소유자 설정"
diagnosisResult= ""
status=""

no_owner_files=()

# Function: Find files and directories without owners
check_no_owner_files() {
    while IFS= read -r -d '' file; do
        # Check if the file owner and group exist, if not add to the array
        if ! getent passwd "$(stat -c "%u" "$file")" > /dev/null || \
           ! getent group "$(stat -c "%g" "$file")" > /dev/null; then
            no_owner_files+=("$file")
        fi
    done < <(find / -nouser -nogroup -print0 2>/dev/null)
}

check_no_owner_files

# Set diagnosis result and status
if [ ${#no_owner_files[@]} -gt 0 ]; then
    diagnosisResult="취약"
    status="소유자가 존재하지 않는 파일 및 디렉터리:\n$(printf '%s\n' "${no_owner_files[@]}")"
fi

# Write diagnosis result to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

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
