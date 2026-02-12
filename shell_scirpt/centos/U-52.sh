#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-52"
riskLevel="중"
diagnosisItem="Telnet 서비스 비활성화"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

############################################
# 변수
############################################
telnet_active=false
현황=()

############################################
# 1. telnet 프로세스 확인
############################################
if ps -ef | grep telnetd | grep -v grep >/dev/null; then
    telnet_active=true
    현황+=("telnetd 프로세스 실행 중")
fi

############################################
# 2. 23번 포트 LISTEN 확인
############################################
if ss -lntup 2>/dev/null | grep ":23 " >/dev/null; then
    telnet_active=true
    현황+=("23번 포트 LISTEN 상태 (telnet 서비스 활성)")
fi

############################################
# 3. systemctl 확인 (Linux)
############################################
if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active telnet.socket >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        telnet_active=true
        현황+=("systemctl telnet.socket 활성화")
    fi

    systemctl is-active telnet >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        telnet_active=true
        현황+=("systemctl telnet 서비스 활성화")
    fi
fi

############################################
# 4. inetd.conf 확인
############################################
if [ -f "/etc/inetd.conf" ]; then
    grep -v "^#" /etc/inetd.conf | grep -i telnet >/dev/null
    if [ $? -eq 0 ]; then
        telnet_active=true
        현황+=("/etc/inetd.conf telnet 활성 설정 존재")
    fi
fi

############################################
# 5. xinetd 확인
############################################
if [ -f "/etc/xinetd.d/telnet" ]; then
    grep -i "disable" /etc/xinetd.d/telnet | grep -i "no" >/dev/null
    if [ $? -eq 0 ]; then
        telnet_active=true
        현황+=("xinetd telnet 활성화 상태")
    fi
fi

############################################
# 결과 판단
############################################
if $telnet_active; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="Telnet 서비스 비활성화 상태"
fi

############################################
# CSV 기록
############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

############################################
# 출력
############################################
cat $OUTPUT_CSV
