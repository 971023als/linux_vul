#!/bin/bash

OUTPUT_CSV="output.csv"

if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status,details" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-01"
riskLevel="상"
diagnosisItem="root 계정 원격접속 제한"
diagnosisResult="양호"
status=""
details=""

# Function to write results to CSV
write_to_csv() {
    echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status,$details" >> $OUTPUT_CSV
}


# 1. Telnet 서비스 검사 (실제 실행 기준)

telnet_active="inactive"

if command -v systemctl >/dev/null 2>&1; then
    telnet_active=$(systemctl is-active telnet.socket 2>/dev/null)
    if [[ "$telnet_active" != "active" ]]; then
        telnet_active=$(systemctl is-active telnet 2>/dev/null)
    fi
fi

if [[ "$telnet_active" == "active" ]]; then
    diagnosisResult="취약"
    status="Telnet 서비스 실행중"
    details="telnet 원격 접속 가능 상태"
    write_to_csv
else
    status="Telnet 서비스 미사용 또는 비활성"
    details="telnet 서비스 비활성 상태"
    write_to_csv
fi


# 2. SSH root 원격접속 검사 (실제 적용값 기준)
root_login_restricted=true
ssh_val="unknown"

if command -v sshd >/dev/null 2>&1; then
    ssh_val=$(sshd -T 2>/dev/null | grep permitrootlogin | awk '{print $2}')
fi

if [[ "$ssh_val" == "no" || "$ssh_val" == "prohibit-password" || "$ssh_val" == "forced-commands-only" ]]; then
    root_login_restricted=true
else
    root_login_restricted=false
fi

if [[ $root_login_restricted == false ]]; then
    diagnosisResult="취약"
    status="SSH root 원격접속 허용"
    details="PermitRootLogin=$ssh_val"
else
    status="SSH root 원격접속 제한"
    details="PermitRootLogin=$ssh_val"
fi

write_to_csv

# 결과 출력
cat $OUTPUT_CSV
