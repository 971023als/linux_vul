#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-21"
위험도="상"
진단_항목="r 계열 서비스 비활성화"
대응방안="불필요한 r 계열 서비스 비활성화"
현황=()

r_commands=("rsh" "rlogin" "rexec" "shell" "login" "exec")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"
vulnerable_services=()

# xinetd.d 아래 서비스 검사
if [ -d "$xinetd_dir" ]; then
    for r_command in "${r_commands[@]}"; do
        service_path="$xinetd_dir/$r_command"
        if [ -f "$service_path" ] && grep -q 'disable\s*=\s*no' "$service_path"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# inetd.conf 아래 서비스 검사
if [ -f "$inetd_conf" ]; then
    for r_command in "${r_commands[@]}"; do
        if grep -q "^$r_command" "$inetd_conf"; then
            vulnerable_services+=("$r_command")
        fi
    done
fi

# 진단 결과 업데이트
if [ ${#vulnerable_services[@]} -gt 0 ]; then
    진단_결과="취약"
    현황+=("불필요한 r 계열 서비스가 실행 중입니다: ${vulnerable_services[*]}")
else
    진단_결과="양호"
    현황+=("모든 r 계열 서비스가 비활성화되어 있습니다.")
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
