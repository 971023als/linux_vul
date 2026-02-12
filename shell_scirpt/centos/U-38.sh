#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-38"
riskLevel="상"
diagnosisItem="DoS 취약 서비스 비활성화"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
vuln=false
현황=()

#########################################
# 점검 대상 포트/서비스
#########################################
declare -A svc_ports
svc_ports=(
["echo"]=7
["discard"]=9
["daytime"]=13
["chargen"]=19
["snmp"]=161
["ntp"]=123
)

#########################################
# 1. inetd.conf 확인
#########################################
if [ -f /etc/inetd.conf ]; then
    for svc in "${!svc_ports[@]}"; do
        if grep -Ei "$svc" /etc/inetd.conf | grep -v '^#' >/dev/null; then
            vuln=true
            현황+=("inetd $svc 활성")
        fi
    done
fi

#########################################
# 2. xinetd 확인
#########################################
for svc in "${!svc_ports[@]}"; do
    if [ -f /etc/xinetd.d/$svc ]; then
        if grep -Ei "disable\s*=\s*no" /etc/xinetd.d/$svc >/dev/null; then
            vuln=true
            현황+=("xinetd $svc 활성")
        fi
    fi
done

#########################################
# 3. 포트 LISTEN 확인
#########################################
for svc in "${!svc_ports[@]}"; do
    port=${svc_ports[$svc]

}
    if ss -lntup 2>/dev/null | grep -E ":$port " >/dev/null; then
        vuln=true
        현황+=("$svc 포트($port) LISTEN")
    fi
done

#########################################
# 4. SNMP systemd 확인
#########################################
if systemctl is-active snmpd 2>/dev/null | grep -q active; then
    vuln=true
    현황+=("snmpd 실행중")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="DoS 취약 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
