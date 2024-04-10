#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-33"
위험도="상"
진단_항목="DNS 보안 버전 패치"
대응방안="DNS 서비스 주기적 패치 관리"
minimum_version="9.18.7"
현황=()

# 버전 비교 함수
compare_versions() {
    if [[ "$1" == "$2" ]]; then
        return 0 # equal
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 1 # less than
        elif ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 2 # greater than
        fi
    done
    return 0 # equal
}

# BIND 버전 확인
if command -v rpm &> /dev/null; then
    bind_version_output=$(rpm -qa | grep '^bind' | grep -oP 'bind(?:9)?-\K(\d+\.\d+\.\d+)')
elif command -v dpkg &> /dev/null; then
    bind_version_output=$(dpkg -l | grep '^ii' | grep 'bind9' | grep -oP 'bind9\s+\K(\d+\.\d+\.\d+)')
fi

# 버전 비교 및 결과 설정
if [[ $bind_version_output ]]; then
    compare_versions $bind_version_output $minimum_version
    case $? in
        1) # less than
            진단_결과="취약"
            현황+=("BIND 버전이 최신 버전(${minimum_version}) 이상이 아닙니다: ${bind_version_output}")
            ;;
        *) # equal or greater than
            진단_결과="양호"
            현황+=("BIND 버전이 최신 버전(${minimum_version}) 이상입니다: ${bind_version_output}")
            ;;
    esac
else
    진단_결과="오류"
    현황+=("BIND가 설치되어 있지 않거나 버전을 확인할 수 없습니다.")
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
