#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-25"
위험도="상"
진단_항목="NFS 접근 통제"
대응방안="불필요한 NFS 서비스를 사용하지 않거나, 사용 시 everyone 공유 제한"
현황=()

# NFS 서비스 실행 상태 확인
if ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'; then
    if [ -f "/etc/exports" ]; then
        # /etc/exports 파일 분석
        if grep -qE '\*' "/etc/exports"; then
            현황+=("/etc/exports 파일에 '*' 설정이 있습니다.")
            진단_결과="취약"
        fi
        if grep -qE 'insecure' "/etc/exports"; then
            현황+=("/etc/exports 파일에 'insecure' 옵션이 설정되어 있습니다.")
            진단_결과="취약"
        fi
        if ! grep -qE 'root_squash|all_squash' "/etc/exports"; then
            현황+=("/etc/exports 파일에 'root_squash' 또는 'all_squash' 옵션이 설정되어 있지 않습니다.")
            진단_결과="취약"
        fi
    else
        현황+=("NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다.")
        진단_결과="취약"
    fi
else
    현황+=("NFS 서비스가 실행 중이지 않습니다.")
    진단_결과="양호"
fi

# 진단 결과가 명시적으로 설정되지 않은 경우 기본값을 "양호"로 설정
if [ -z "$진단_결과" ]; then
    진단_결과="양호"
    현황+=("NFS 접근 통제 설정에 문제가 없습니다.")
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
