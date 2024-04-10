#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-24"
위험도="상"
진단_항목="NFS 서비스 비활성화"
대응방안="불필요한 NFS 서비스 관련 데몬 비활성화"
현황=()

# NFS 관련 프로세스 확인
if ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'; then
    진단_결과="취약"
    현황+=("불필요한 NFS 서비스 관련 데몬이 실행 중입니다.")
else
    진단_결과="양호"
    현황+=("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
