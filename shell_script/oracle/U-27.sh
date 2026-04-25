#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-27"
riskLevel="상"
diagnosisItem="RPC 서비스 확인"
solution="불필요한 RPC 서비스 비활성화"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 불필요한 RPC 서비스가 비활성화되어 있습니다.
[취약]: 불필요한 RPC 서비스가 실행 중입니다.
EOF

rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"
service_found=false

# Check services under /etc/xinetd.d
if [ -d "$xinetd_dir" ]; then
    for service in "${rpc_services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -q 'disable\s*=\s*yes' "$service_path"; then
                diagnosisResult="불필요한 RPC 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다: $service"
                status="취약"
                service_found=true
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
        fi
    done
fi

# Check services in /etc/inetd.conf
if [ -f "$inetd_conf" ]; then
    for service in "${rpc_services[@]}"; do
        if grep -q "$service" "$inetd_conf"; then
            diagnosisResult="불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다: $service"
            status="취약"
            service_found=true
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
    done
fi

# Final check if no vulnerabilities found
if ! $service_found; then
    diagnosisResult="모든 불필요한 RPC 서비스가 비활성화되어 있습니다."
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
