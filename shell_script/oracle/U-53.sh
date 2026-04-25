#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-53"
riskLevel="하"
diagnosisItem="사용자 shell 점검"
service="Account Management"
diagnosisResult=""
status="양호"

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# 불필요한 계정 목록
unnecessary_accounts=(
    "daemon" "bin" "sys" "adm" "listen" "nobody" "nobody4"
    "noaccess" "diag" "operator" "gopher" "games" "ftp" "apache"
    "httpd" "www-data" "mysql" "mariadb" "postgres" "mail" "postfix"
    "news" "lp" "uucp" "nuucp"
)

if [ -f "/etc/passwd" ]; then
    found_issues=false
    while IFS=: read -r username _ _ _ _ _ shell; do
        for account in "${unnecessary_accounts[@]}"; do
            if [ "$username" == "$account" ] && [ "$shell" != "/bin/false" ] && [ "$shell" != "/sbin/nologin" ]; then
                diagnosisResult="계정 $username에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다."
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
                found_issues=true
                break 2
            fi
        done
    done < /etc/passwd

    if [ "$found_issues" = false ]; then
        diagnosisResult="모든 불필요한 계정에 대해 적절한 쉘이 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/passwd 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
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
