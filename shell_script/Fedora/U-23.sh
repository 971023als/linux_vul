#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-23"
riskLevel="상"
diagnosisItem="DoS 공격에 취약한 서비스 비활성화"
solution="사용하지 않는 DoS 공격에 취약한 서비스 비활성화"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.
[취약]: DoS 공격에 취약한 서비스가 실행 중입니다.
EOF

vulnerable_services=("echo" "discard" "daytime" "chargen")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# Check services under /etc/xinetd.d
if [ -d "$xinetd_dir" ]; then
    for service in "${vulnerable_services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -Eiq '^[\s]*disable[\s]*=[\s]*yes' "$service_path"; then
                diagnosisResult="$service 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
        fi
    done
fi

# Check services in /etc/inetd.conf
if [ -f "$inetd_conf" ]; then
    for service in "${vulnerable_services[@]}"; do
        if grep -Eiq "^$service" "$inetd_conf"; then
            diagnosisResult="$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    done
fi

# Final check if no vulnerabilities found
if [ -z "$diagnosisResult" ]; then
    diagnosisResult="모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo


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
