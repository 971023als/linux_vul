#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-59"
riskLevel="상"
diagnosisItem="안전한 SNMP 버전 사용"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
snmp_running=false
snmp_v3_used=false
v12_used=false
현황=()

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

    conf="/etc/snmp/snmpd.conf"

    if [ -f "$conf" ]; then

        #############################################
        # v1/v2 community 체크
        #############################################
        grep -Ei "community|rocommunity|rwcommunity" "$conf" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            v12_used=true
            현황+=("SNMP v1/v2 community 사용")
        fi

        #############################################
        # v3 사용자 체크
        #############################################
        grep -Ei "usmUser|createUser|rouser|rwuser" "$conf" | grep -v '^#' >/dev/null
        if [ $? -eq 0 ]; then
            snmp_v3_used=true
            현황+=("SNMP v3 사용자 설정 존재")
        fi
    fi

    #############################################
    # 포트 확인 (참고)
    #############################################
    if ss -lunp 2>/dev/null | grep ":161" >/dev/null; then
        현황+=("UDP 161 SNMP 포트 사용중")
    fi

    #############################################
    # 결과 판단
    #############################################
    if $snmp_v3_used && ! $v12_used; then
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${현황[*]}")
    else
        diagnosisResult="취약"
        if [ ${#현황[@]} -eq 0 ]; then
            status="SNMP v3 설정 없음"
        else
            status=$(IFS=' | '; echo "${현황[*]}")
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
