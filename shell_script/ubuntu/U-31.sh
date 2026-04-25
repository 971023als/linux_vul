#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-31"
riskLevel="상"
diagnosisItem="스팸 메일 릴레이 제한"
solution="SMTP 서비스 릴레이 제한 설정"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

search_directory='/etc/mail/'
vulnerable_found=false
_status_list=()

# Search for sendmail.cf files and analyze their contents
find "$search_directory" -name 'sendmail.cf' -type f | while read -r file_path; do
    if [ -f "$file_path" ]; then
        if grep -qE 'R\$\*' "$file_path" || grep -qEi 'Relaying denied' "$file_path"; then
            _status_list+=("$file_path 파일에 릴레이 제한이 적절히 설정되어 있습니다.")
        else
            vulnerable_found=true
            _status_list+=("$file_path 파일에 릴레이 제한 설정이 없습니다.")
        fi
    fi
done

# Determine the diagnosis result
if $vulnerable_found; then
    diagnosisResult="릴레이 제한 설정이 없습니다."
    status="취약"
else
    if [ ${#_status_list[@]} -eq 0 ]; then
        diagnosisResult="sendmail.cf 파일을 찾을 수 없거나 접근할 수 없습니다."
        status="양호"
    else
        diagnosisResult="릴레이 제한이 적절히 설정되어 있습니다."
        status="양호"
    fi
fi

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
