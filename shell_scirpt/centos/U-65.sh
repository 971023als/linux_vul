#!/bin/bash

OUTPUT_CSV="output.csv"

if [ ! -f $OUTPUT_CSV ]; then
echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

category="로그 관리"
code="U-65"
riskLevel="중"
diagnosisItem="NTP 시각 동기화 설정"

result="양호"
status=""

#########################################
# 1. chrony / ntp 서비스 확인
#########################################
if systemctl is-active chronyd >/dev/null 2>&1; then
    time_service="chrony"
elif systemctl is-active ntpd >/dev/null 2>&1; then
    time_service="ntp"
elif systemctl is-active systemd-timesyncd >/dev/null 2>&1; then
    time_service="timesyncd"
else
    time_service="none"
    result="취약"
    status="NTP 서비스 미동작"
fi

status="service:$time_service"

#########################################
# 2. 동기화 서버 확인
#########################################
if [ "$time_service" == "chrony" ]; then
    servers=$(grep ^server /etc/chrony.conf 2>/dev/null | awk '{print $2}')
elif [ "$time_service" == "ntp" ]; then
    servers=$(grep ^server /etc/ntp.conf 2>/dev/null | awk '{print $2}')
elif [ "$time_service" == "timesyncd" ]; then
    servers=$(grep ^NTP /etc/systemd/timesyncd.conf 2>/dev/null | cut -d= -f2)
else
    servers="none"
fi

status="$status | ntp_servers:$servers"

#########################################
# 3. 동기화 상태 확인
#########################################
sync_status="unknown"

if [ "$time_service" == "chrony" ]; then
    sync_status=$(chronyc tracking 2>/dev/null | grep "Leap status" | awk -F: '{print $2}')
elif [ "$time_service" == "ntp" ]; then
    sync_status=$(ntpq -pn 2>/dev/null | grep ^* | wc -l)
elif [ "$time_service" == "timesyncd" ]; then
    sync_status=$(timedatectl | grep "System clock synchronized" | awk '{print $4}')
fi

status="$status | sync:$sync_status"

#########################################
# 4. 판단 기준
#########################################
if [ "$time_service" == "none" ]; then
    result="취약"
elif [ -z "$servers" ]; then
    result="취약"
    status="$status | NTP 서버 미설정"
else
    result="양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$result,\"$status\"" >> $OUTPUT_CSV

cat $OUTPUT_CSV
