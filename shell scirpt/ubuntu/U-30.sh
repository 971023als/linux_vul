#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-30"
위험도="상"
진단_항목="Sendmail 버전 점검"
대응방안="Sendmail 버전을 최신 버전으로 유지"
현황=()

latest_version="8.17.1"  # 최신 Sendmail 버전 예시

# RPM-based systems에서 Sendmail 버전 확인
sendmail_version=$(rpm -qa | grep 'sendmail' | grep -oP 'sendmail-\K(\d+\.\d+\.\d+)')

# 버전 비교 및 결과 설정
if [[ $sendmail_version ]]; then
    if [[ $sendmail_version == $latest_version* ]]; then
        진단_결과="양호"
        현황+=("Sendmail 버전이 최신 버전(${latest_version})입니다.")
    else
        진단_결과="취약"
        현황+=("Sendmail 버전이 최신 버전(${latest_version})이 아닙니다. 현재 버전: ${sendmail_version}")
    fi
else
    진단_결과="양호"
    현황+=("Sendmail이 설치되어 있지 않습니다.")
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
