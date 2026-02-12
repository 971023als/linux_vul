#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-41"
riskLevel="상"
diagnosisItem="불필요한 automountd 비활성화"
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
# 1. systemd autofs 서비스
#########################################
if systemctl is-active autofs 2>/dev/null | grep -q active; then
    vuln=true
    현황+=("autofs 서비스 실행중")
fi

#########################################
# 2. 프로세스 확인
#########################################
if ps -ef | grep -E "automount|automountd|autofs" | grep -v grep >/dev/null; then
    vuln=true
    현황+=("automount 프로세스 실행중")
fi

#########################################
# 3. 포트/RPC 확인
#########################################
if ss -lntup 2>/dev/null | grep rpc >/dev/null; then
    rpc_used=true
else
    rpc_used=false
fi

#########################################
# 4. 패키지 설치 확인 (참고)
#########################################
if rpm -qa 2>/dev/null | grep -i autofs >/dev/null; then
    현황+=("autofs 패키지 설치됨")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="automountd 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
