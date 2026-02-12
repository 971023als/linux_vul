#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-34"
riskLevel="상"
diagnosisItem="Finger 서비스 비활성화"
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
# 1. inetd.conf 확인
#########################################
if [ -f /etc/inetd.conf ]; then
    if grep -Ei "finger" /etc/inetd.conf | grep -v '^#' >/dev/null; then
        vuln=true
        현황+=("inetd finger 활성")
    fi
fi

#########################################
# 2. xinetd 확인
#########################################
if [ -f /etc/xinetd.d/finger ]; then
    if grep -Ei "disable\s*=\s*no" /etc/xinetd.d/finger >/dev/null; then
        vuln=true
        현황+=("xinetd finger 활성")
    fi
fi

#########################################
# 3. systemd 서비스 확인
#########################################
if systemctl list-unit-files 2>/dev/null | grep -i finger >/dev/null; then
    if systemctl is-active finger.socket 2>/dev/null | grep -q active; then
        vuln=true
        현황+=("systemd finger 활성")
    fi
fi

#########################################
# 4. 포트 79 리스닝 확인
#########################################
if ss -lntup 2>/dev/null | grep ":79 " >/dev/null; then
    vuln=true
    현황+=("finger 포트79 LISTEN")
fi

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="Finger 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
