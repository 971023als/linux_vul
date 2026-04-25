#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정 관리"
code="U-02"
riskLevel="상"
diagnosisItem="패스워드 복잡성 설정"
diagnosisResult=""
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

# Initial values for diagnosis
min_length=8
declare -A min_input_requirements=( [lcredit]=-1 [ucredit]=-1 [dcredit]=-1 [ocredit]=-1 )
files_to_check=(
    "/etc/login.defs"
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
    "/etc/security/pwquality.conf"
)
password_settings_found=false
_status_list=()

for file_path in "${files_to_check[@]}"; do
    if [[ -f "$file_path" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | xargs)
            if [[ ! "$line" =~ ^# && ! -z "$line" ]]; then
                if [[ "$line" =~ PASS_MIN_LEN || "$line" =~ minlen ]]; then
                    password_settings_found=true
                    value=$(echo "$line" | grep -o '[0-9]*')
                    if (( value < min_length )); then
                        _status_list+=("$file_path에서 설정된 패스워드 최소 길이가 ${min_length}자 미만입니다.")
                    fi
                fi
                for key in "${!min_input_requirements[@]}"; do
                    if [[ "$line" =~ $key ]]; then
                        password_settings_found=true
                        value=$(echo "$line" | sed -n "s/.*$key\s*\(-\?\d\+\).*/\1/p")
                        if (( value < min_input_requirements[$key] )); then
                            _status_list+=("$file_path에서 $key 설정이 ${min_input_requirements[$key]} 미만입니다.")
                        fi
                    fi
                done
            fi
        done < "$file_path"
    fi
done

if $password_settings_found; then
    if [ ${#_status_list[@]} -eq 0 ]; then
        diagnosisResult="양호"
        status="패스워드 복잡성 설정이 적절하게 구성되어 있습니다."
    else
        diagnosisResult="취약"
        status=$(IFS=$'\n'; echo "${_status_list[*]}")
    fi
else
    diagnosisResult="취약"
    status="패스워드 복잡성 설정이 없습니다."
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
