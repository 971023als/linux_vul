#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-28"
riskLevel="상"
diagnosisItem="접속 IP 및 포트 제한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
vuln=false
현황=()

#########################################
# 1. TCP Wrapper 점검
#########################################
hosts_deny="/etc/hosts.deny"
hosts_allow="/etc/hosts.allow"
tcp_ok=false

if [ -f "$hosts_deny" ]; then
    if grep -Eq "ALL:ALL" "$hosts_deny"; then
        tcp_ok=true
    fi
fi

#########################################
# 2. iptables 점검
#########################################
iptables_ok=false
if command -v iptables >/dev/null 2>&1; then
    rules=$(iptables -L 2>/dev/null | grep -v "Chain")
    if [[ -n "$rules" ]]; then
        iptables_ok=true
    fi
fi

#########################################
# 3. firewalld 점검
#########################################
firewall_ok=false
if command -v firewall-cmd >/dev/null 2>&1; then
    state=$(firewall-cmd --state 2>/dev/null)
    if [[ "$state" == "running" ]]; then
        firewall_ok=true
    fi
fi

#########################################
# 결과 판정
#########################################
if $tcp_ok || $iptables_ok || $firewall_ok; then
    diagnosisResult="양호"
    status="IP/포트 접근제어 설정 존재"
else
    diagnosisResult="취약"
    status="접근제어 설정 없음 (hosts.allow/deny, iptables, firewalld)"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
