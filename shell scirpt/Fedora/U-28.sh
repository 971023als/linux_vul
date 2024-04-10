#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-28"
위험도="상"
진단_항목="NIS, NIS+ 점검"
대응방안="NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
현황=()

# NIS 관련 프로세스 실행 상태 확인
if ps -ef | grep -E '[y]pserv|[y]pbind|[y]pxfrd|[r]pc.yppasswdd|[r]pc.ypupdated' &> /dev/null; then
    # NIS 관련 프로세스가 실행 중임
    진단_결과="취약"
    현황+=("NIS 서비스가 실행 중입니다.")
else
    # NIS 관련 프로세스가 실행 중이지 않음
    진단_결과="양호"
    현황+=("NIS 서비스가 비활성화되어 있습니다.")
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
