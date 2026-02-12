#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-43"
riskLevel="상"
diagnosisItem="NIS/NIS+ 서비스 점검"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
nis_used=false
nisplus_used=false
현황=()

#########################################
# 1. NIS 프로세스 확인
#########################################
nis_services=("ypserv" "ypbind" "ypxfrd" "rpc.yppasswdd" "rpc.ypupdated")

for svc in "${nis_services[@]}"; do
    if ps -ef | grep "$svc" | grep -v grep >/dev/null; then
        nis_used=true
        현황+=("$svc 실행중")
    fi
done

#########################################
# 2. systemd 확인
#########################################
for svc in ypserv ypbind; do
    if systemctl is-active $svc 2>/dev/null | grep -q active; then
        nis_used=true
        현황+=("$svc systemd active")
    fi
done

#########################################
# 3. NIS+ 확인
#########################################
if ps -ef | grep rpc.nisd | grep -v grep >/dev/null; then
    nisplus_used=true
    현황+=("NIS+ 사용중")
fi

#########################################
# 4. nsswitch.conf 확인
#########################################
if [ -f /etc/nsswitch.conf ]; then
    if grep -E "passwd|group|shadow" /etc/nsswitch.conf | grep nis >/dev/null; then
        nis_used=true
        현황+=("nsswitch nis 사용")
    fi
fi

#########################################
# 5. 포트 확인 (yp)
#########################################
if ss -lntup 2>/dev/null | grep -E ":111 |:834 " >/dev/null; then
    현황+=("NIS 관련 포트 사용")
fi

#########################################
# 결과
#########################################
if $nis_used && ! $nisplus_used; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    if $nisplus_used; then
        status="NIS+ 사용 (양호)"
    else
        status="NIS 서비스 비활성화"
    fi
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
