#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-39"
riskLevel="상"
diagnosisItem="불필요한 NFS 서비스 비활성화"
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
# 1. systemd 서비스 확인
#########################################
if systemctl is-active nfs-server 2>/dev/null | grep -q active; then
    vuln=true
    현황+=("nfs-server 실행중")
fi

if systemctl is-active nfs 2>/dev/null | grep -q active; then
    vuln=true
    현황+=("nfs 서비스 실행중")
fi

if systemctl is-active rpcbind 2>/dev/null | grep -q active; then
    vuln=true
    현황+=("rpcbind 실행중")
fi

#########################################
# 2. 프로세스 확인
#########################################
if ps -ef | grep -E "nfsd|rpc.statd|rpc.mountd" | grep -v grep >/dev/null; then
    vuln=true
    현황+=("NFS 관련 프로세스 실행")
fi

#########################################
# 3. 공유 설정 확인 (/etc/exports)
#########################################
if [ -f /etc/exports ]; then
    if grep -v '^#' /etc/exports | grep '/' >/dev/null; then
        vuln=true
        현황+=("NFS 공유 설정 존재")
    fi
fi

#########################################
# 4. 포트 확인
#########################################
if ss -lntup 2>/dev/null | grep -E ":2049 |:111 " >/dev/null; then
    vuln=true
    현황+=("NFS 관련 포트 LISTEN(2049/111)")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="NFS 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
