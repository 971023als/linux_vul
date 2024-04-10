#!/bin/bash

# 최소 요구 버전 설정
minimum_version="9.18.7"

# 버전 비교 함수 정의
version_compare() {
    if [[ "$1" == "$2" ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 1
        elif ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# BIND 버전 확인
bind_version=$(named -v | grep -oP 'BIND \K[\d\.]+')

# 버전 확인 결과에 따른 조치
if [[ -n $bind_version ]]
then
    version_compare $bind_version $minimum_version
    result=$?
    if [[ $result -eq 2 ]] || [[ $result -eq 0 ]]
    then
        echo "BIND 버전 ($bind_version)이 최소 요구 버전 ($minimum_version) 이상입니다."
    else
        echo "BIND 버전 ($bind_version)이 최소 요구 버전 ($minimum_version) 이하입니다. 업데이트가 필요합니다."
        # 업데이트 권장 메시지
        echo "BIND를 업데이트하려면, 시스템의 패키지 관리자를 사용하세요."
    fi
else
    echo "BIND 버전을 확인할 수 없습니다. BIND가 설치되어 있는지 확인하세요."
fi
