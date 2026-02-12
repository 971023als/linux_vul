#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-60"
riskLevel="중"
diagnosisItem="SNMP Community String 복잡성 설정"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
snmp_running=false
weak_found=false
strong_found=false
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
    # 3. SNMPv3 사용자 존재 여부
    #############################################
    if [ -f "$conf" ]; then
        grep -Ei "usmUser|createUser|rwuser|rouser" "$conf" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            diagnosisResult="양호"
            status="SNMPv3 사용 (Community String 미사용)"
            echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV
            cat $OUTPUT_CSV
            exit 0
        fi
    fi

    #############################################
    # 4. community string 검사
    #############################################
    if [ -f "$conf" ]; then

        communities=$(grep -Ei "rocommunity|rwcommunity|community" "$conf" | grep -v '^#' | awk '{print $2}')

        for comm in $communities; do

            # 기본값 검사
            if [[ "$comm" == "public" || "$comm" == "private" ]]; then
                weak_found=true
                현황+=("기본 community 사용: $comm")
                continue
            fi

            # 길이 및 복잡성 검사
            len=${#comm}

            if [[ $comm =~ [A-Za-z] && $comm =~ [0-9] && $len -ge 10 ]]; then
                strong_found=true
                현황+=("복잡성 양호: $comm")
            elif [[ $comm =~ [A-Za-z] && $comm =~ [0-9] && $comm =~ [^A-Za-z0-9] && $len -ge 8 ]]; then
                strong_found=true
                현황+=("복잡성 양호(특수문자 포함): $comm")
            else
                weak_found=true
                현황+=("복잡성 취약: $comm")
            fi
        done
    fi

    #############################################
    # 결과 판단
    #############################################
    if $weak_found; then
        diagnosisResult="취약"
        status=$(IFS=' | '; echo "${현황[*]}")
    elif $strong_found; then
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${현황[*]}")
    else
        diagnosisResult="취약"
        status="SNMP Community String 설정 없음"
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
