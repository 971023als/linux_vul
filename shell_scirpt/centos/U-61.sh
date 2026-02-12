#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-61"
riskLevel="상"
diagnosisItem="SNMP Access Control 설정"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
snmp_running=false
access_ok=false
weak_access=false
현황=()

conf="/etc/snmp/snmpd.conf"

#############################################
# 1. SNMP 실행 여부
#############################################
if ps -ef | grep snmpd | grep -v grep >/dev/null; then
    snmp_running=true
fi

if systemctl is-active snmpd 2>/dev/null | grep -q active; then
    snmp_running=true
fi

#############################################
# 2. SNMP 미사용 → 양호
#############################################
if ! $snmp_running; then
    diagnosisResult="양호"
    status="SNMP 서비스 미사용"

else

    #############################################
    # 설정파일 존재 확인
    #############################################
    if [ ! -f "$conf" ]; then
        diagnosisResult="취약"
        status="snmpd.conf 설정파일 없음"

    else

        #############################################
        # SNMPv3 access control (양호)
        #############################################
        grep -Ei "rouser|rwuser" "$conf" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            access_ok=true
            현황+=("SNMPv3 사용자 기반 접근통제 설정")
        fi

        #############################################
        # com2sec 기반 접근제어
        #############################################
        grep -Ei "^com2sec" "$conf" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            access_ok=true
            현황+=("com2sec 접근제어 설정")
        fi

        #############################################
        # rocommunity/rwcommunity IP 제한 확인
        #############################################
        lines=$(grep -Ei "rocommunity|rwcommunity" "$conf" | grep -v '^#')

        if [ -n "$lines" ]; then
            while read -r line; do
                # any/all/default 허용 탐지
                if echo "$line" | grep -Ei "default|0.0.0.0|any|ALL" >/dev/null; then
                    weak_access=true
                    현황+=("전체 허용 설정 발견: $line")
                else
                    access_ok=true
                    현황+=("IP 제한 설정: $line")
                fi
            done <<< "$lines"
        fi

        #############################################
        # 결과 판단
        #############################################
        if $access_ok && ! $weak_access; then
            diagnosisResult="양호"
            status=$(IFS=' | '; echo "${현황[*]}")
        else
            diagnosisResult="취약"
            if [ ${#현황[@]} -eq 0 ]; then
                status="SNMP 접근제어 설정 없음"
            else
                status=$(IFS=' | '; echo "${현황[*]}")
            fi
        fi
    fi
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
