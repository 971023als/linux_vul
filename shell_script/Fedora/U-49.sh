#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-49"
riskLevel="하"
diagnosisItem="불필요한 계정 제거"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# 로그인이 가능한 쉘 목록
login_shells=("/bin/bash" "/bin/sh")
# 검사할 불필요한 계정 목록
unnecessary_accounts=("user" "test" "guest" "info" "adm" "mysql" "user1")

# 불필요한 계정 찾기
found_accounts=()
for account in "${unnecessary_accounts[@]}"; do
    if getent passwd "$account" > /dev/null; then
        shell=$(getent passwd "$account" | cut -d: -f7)
        for login_shell in "${login_shells[@]}"; do
            if [[ "$shell" == "$login_shell" ]]; then
                found_accounts+=("$account")
                break
            fi
        done
    fi
done

if [ ${#found_accounts[@]} -gt 0 ]; then
    diagnosisResult="불필요한 계정이 존재합니다: ${found_accounts[*]}"
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
else
    diagnosisResult="불필요한 계정이 존재하지 않습니다."
    status="양호"
    echo "OK: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

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
