#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-23"
위험도="상"
진단_항목="DoS 공격에 취약한 서비스 비활성화"
대응방안="사용하지 않는 DoS 공격에 취약한 서비스 비활성화"
현황=()

vulnerable_services=("echo" "discard" "daytime" "chargen")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# /etc/xinetd.d 아래 서비스 검사
if [ -d "$xinetd_dir" ]; then
    for service in "${vulnerable_services[@]}"; do
        service_path="$xinetd_dir/$service"
        if [ -f "$service_path" ]; then
            if ! grep -Eiq '^[\s]*disable[\s]*=[\s]*yes' "$service_path"; then
                진단_결과="취약"
                현황+=("$service 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.")
            fi
        fi
    done
fi

# /etc/inetd.conf 파일 내 서비스 검사
if [ -f "$inetd_conf" ]; then
    for service in "${vulnerable_services[@]}"; do
        if grep -Eiq "^$service" "$inetd_conf"; then
            진단_결과="취약"
            현황+=("$service 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
        fi
    done
fi

# 진단 결과 결정
if [ -z "$진단_결과" ]; then
    진단_결과="양호"
    현황+=("모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.")
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
