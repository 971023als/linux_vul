#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-26"
위험도="상"
진단_항목="automountd 제거"
대응방안="automountd 서비스 비활성화"
현황=()

# automountd 또는 autofs 서비스 실행 상태 확인
if ps -ef | grep -iE '[a]utomount|[a]utofs' &> /dev/null; then
    # automountd 또는 autofs 서비스가 실행 중임
    진단_결과="취약"
    현황+=("automountd 서비스가 실행 중입니다.")
else
    # automountd 또는 autofs 서비스가 실행 중이지 않음
    진단_결과="양호"
    현황+=("automountd 서비스가 비활성화되어 있습니다.")
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
