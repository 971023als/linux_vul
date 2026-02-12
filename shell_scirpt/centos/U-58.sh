#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-58"
riskLevel="중"
diagnosisItem="불필요한 SNMP 서비스 구동 점검"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
snmp_running=false
현황=()

#############################################
# 1. SNMP 프로세스 확인
#############################################
if ps -ef | grep snmpd | grep -v grep >/dev/null; then
    snmp_running=true
    현황+=("snmpd 프로세스 실행중")
fi

#############################################
# 2. systemctl 서비스 확인
#############################################
if systemctl is-active snmpd 2>/dev/null | grep -q active; then
    snmp_running=true
    현황+=("snmpd 서비스 active 상태")
fi

#############################################
# 3. UDP 161 포트 확인
#############################################
if ss -lunp 2>/dev/null | grep ":161" >/dev/null; then
    snmp_running=true
    현황+=("SNMP 161 UDP 포트 사용중")
fi

#############################################
# 4. 패키지 설치 여부 (참고)
#############################################
if rpm -qa 2>/dev/null | grep -i net-snmp >/dev/null; then
    현황+=("net-snmp 패키지 설치됨")
fi

#############################################
# 결과 판단
#############################################
if $snmp_running; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="SNMP 서비스 미사용"
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
