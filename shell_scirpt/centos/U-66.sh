#!/bin/bash

OUTPUT_CSV="output.csv"

if [ ! -f $OUTPUT_CSV ]; then
echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

category="로그 관리"
code="U-66"
riskLevel="중"
diagnosisItem="정책 기반 시스템 로깅 설정"

result="양호"
status=""

#########################################
# 1. 로깅 서비스 확인
#########################################
log_service="none"

if systemctl is-active rsyslog >/dev/null 2>&1; then
    log_service="rsyslog"
elif systemctl is-active syslog >/dev/null 2>&1; then
    log_service="syslog"
elif systemctl is-active syslog-ng >/dev/null 2>&1; then
    log_service="syslog-ng"
else
    result="취약"
    status="로그 서비스 미동작"
fi

status="service:$log_service"

#########################################
# 2. 설정파일 존재 확인
#########################################
config_file=""

if [ "$log_service" == "rsyslog" ]; then
    config_file="/etc/rsyslog.conf"
elif [ "$log_service" == "syslog-ng" ]; then
    config_file="/etc/syslog-ng/syslog-ng.conf"
elif [ "$log_service" == "syslog" ]; then
    config_file="/etc/syslog.conf"
fi

if [ ! -f "$config_file" ]; then
    result="취약"
    status="$status | 설정파일 없음"
else
    status="$status | config:$config_file"
fi

#########################################
# 3. 주요 로그 정책 존재 확인
#########################################
auth_log=$(grep -E "auth|authpriv" $config_file 2>/dev/null)
cron_log=$(grep cron $config_file 2>/dev/null)
mail_log=$(grep mail $config_file 2>/dev/null)
sys_log=$(grep "\*\.info" $config_file 2>/dev/null)

if [ -z "$auth_log" ]; then
    result="취약"
    status="$status | auth 로그 미설정"
fi

if [ -z "$sys_log" ]; then
    result="취약"
    status="$status | system 로그 미설정"
fi

#########################################
# 4. 실제 로그 파일 존재 여부
#########################################
log_paths="/var/log/messages /var/log/secure /var/log/auth.log"

for log in $log_paths
do
    if [ -f "$log" ]; then
        status="$status | log_exist:$log"
    fi
done

#########################################
# 5. 결과 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$result,\"$status\"" >> $OUTPUT_CSV

cat $OUTPUT_CSV
