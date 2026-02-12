#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-21"
riskLevel="상"
diagnosisItem="r 계열 서비스 비활성화"
solution="불필요한 r 계열 서비스 비활성화"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 r 계열 서비스가 비활성화되어 있습니다.
[취약]: 불필요한 r 계열 서비스가 실행 중입니다.
EOF

r_commands=("rsh" "rlogin" "rexec" "shell" "login" "exec")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"
vulnerable_services=()

# Check services under xinetd.d
if [ -d "$xinetd_dir" ]; then
    for r_command in "${r_commands[@]}"; do
        service_path="$xinetd_dir/$r_command"
        if [ -f "$service_path" ] && grep -q 'disable\s*=\s*no' "$service_path"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# Check services in inetd.conf
if [ -f "$inetd_conf" ]; then
    for r_command in "${r_commands[@]}"; do
        if grep -q "^$r_command" "$inetd_conf"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# Update diagnosis result
if [ ${#vulnerable_services[@]} -gt 0 ]; then
    diagnosisResult="불필요한 r 계열 서비스가 실행 중입니다: ${vulnerable_services[*]}"
    status="취약"
    echo "WARN: $diagnosisResult" >> $TMP1
else
    diagnosisResult="모든 r 계열 서비스가 비활성화되어 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
fi

# Write results to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV

cat $TMP1

echo ; echo

cat $OUTPUT_CSV
