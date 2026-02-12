#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-44"
riskLevel="상"
diagnosisItem="tftp, talk 서비스 비활성화"
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
# 점검 대상 서비스
#########################################
services=("tftp" "talk" "ntalk")

#########################################
# 1. inetd.conf 확인
#########################################
if [ -f /etc/inetd.conf ]; then
    for svc in "${services[@]}"; do
        if grep -Ei "$svc" /etc/inetd.conf | grep -v '^#' >/dev/null; then
            vuln=true
            현황+=("inetd $svc 활성")
        fi
    done
fi

#########################################
# 2. xinetd 확인
#########################################
for svc in "${services[@]}"; do
    if [ -f /etc/xinetd.d/$svc ]; then
        if grep -Ei "disable\s*=\s*no" /etc/xinetd.d/$svc >/dev/null; then
            vuln=true
            현황+=("xinetd $svc 활성")
        fi
    fi
done

#########################################
# 3. systemd 확인
#########################################
for svc in "${services[@]}"; do
    if systemctl list-unit-files 2>/dev/null | grep -i "$svc" >/dev/null; then
        if systemctl is-active $svc 2>/dev/null | grep -q active; then
            vuln=true
            현황+=("systemd $svc 실행중")
        fi
    fi
done

#########################################
# 4. 포트 LISTEN 확인
#########################################
# tftp=69, talk=517, ntalk=518
if ss -lntup 2>/dev/null | grep -E ":69 |:517 |:518 " >/dev/null; then
    vuln=true
    현황+=("tftp/talk 포트 LISTEN")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="tftp/talk 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
