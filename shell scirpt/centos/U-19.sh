#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-19"
위험도="상"
진단_항목="Finger 서비스 비활성화"
대응방안="Finger 서비스가 비활성화 되어 있는 경우"
현황=()
진단_결과=""

# /etc/services에서 Finger 서비스 정의 확인
if grep -iq "^finger.*tcp" /etc/services; then
    현황+=("Finger 서비스 포트가 /etc/services에 정의되어 있습니다.")
    진단_결과="취약"
else
    if [ ! -f "/etc/services" ]; then
        현황+=("/etc/services 파일을 찾을 수 없습니다.")
    fi
fi

# Finger 프로세스 실행 중인지 확인
if ps -ef | grep -iq "finger"; then
    현황+=("Finger 서비스 프로세스가 실행 중입니다.")
    진단_결과="취약"
fi

if [ -z "$진단_결과" ]; then
    진단_결과="양호"
    현황+=("Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다.")
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
