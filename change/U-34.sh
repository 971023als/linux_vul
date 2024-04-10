#!/bin/bash

read -p "허가된 IP 주소를 입력하세요 (예: 192.168.1.100): " allowed_ip

named_conf_path="/etc/named.conf"

# named.conf 파일이 존재하는지 확인
if [ -f "$named_conf_path" ]; then
    # allow-transfer 옵션이 설정된 부분을 찾아 입력받은 IP로 변경
    if grep -q "allow-transfer" "$named_conf_path"; then
        sed -i "/allow-transfer/c\allow-transfer { $allowed_ip; };" "$named_conf_path"
        echo "DNS Zone Transfer 설정이 업데이트되었습니다: $allowed_ip 에게만 허용"
    else
        # allow-transfer 옵션이 없는 경우, options 섹션에 추가
        sed -i "/options {/a \\\tallow-transfer { $allowed_ip; };" "$named_conf_path"
        echo "DNS Zone Transfer 설정이 추가되었습니다: $allowed_ip 에게만 허용"
    fi
else
    echo "/etc/named.conf 파일이 존재하지 않습니다. DNS 서비스 설정 파일을 찾을 수 없습니다."
fi

# DNS 서비스 재시작 (BIND9 예시)
if systemctl is-active --quiet named; then
    systemctl restart named
    echo "DNS 서비스(named)가 재시작되었습니다."
else
    echo "DNS 서비스(named)가 실행 중이지 않습니다. 설정 변경 후 수동으로 서비스를 시작하세요."
fi
