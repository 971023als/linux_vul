#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-42"
riskLevel="상"
diagnosisItem="불필요한 RPC 서비스 비활성화"
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
# 취약 RPC 목록
#########################################
rpc_list=(
rpc.cmsd rpc.ttdbserverd sadmind rusersd walld sprayd rstatd
rpc.nisd rexd rpc.pcnfsd rpc.statd rpc.ypupdated rpc.rquotad
kcms_server cachefsd
)

#########################################
# 1. 프로세스 실행 확인
#########################################
for svc in "${rpc_list[@]}"; do
    if ps -ef | grep "$svc" | grep -v grep >/dev/null; then
        vuln=true
        현황+=("$svc 실행중")
    fi
done

#########################################
# 2. inetd.conf 확인
#########################################
if [ -f /etc/inetd.conf ]; then
    for svc in "${rpc_list[@]}"; do
        if grep -Ei "$svc" /etc/inetd.conf | grep -v '^#' >/dev/null; then
            vuln=true
            현황+=("inetd $svc 활성")
        fi
    done
fi

#########################################
# 3. rpcbind 실행 여부 (참고)
#########################################
if systemctl is-active rpcbind 2>/dev/null | grep -q active; then
    현황+=("rpcbind 실행중")
fi

#########################################
# 4. RPC 포트 LISTEN 확인
#########################################
if ss -lntup 2>/dev/null | grep rpc >/dev/null; then
    현황+=("RPC 포트 LISTEN")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="불필요 RPC 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
