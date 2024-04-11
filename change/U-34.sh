#!/bin/bash

# named.conf 파일의 경로
named_conf_path="/etc/named.conf"

# DNS 서비스 실행 여부 및 named.conf 파일 존재 여부 확인
if pgrep named > /dev/null && [ -f "$named_conf_path" ]; then
    # allow-transfer 설정 검사
    if grep -q 'allow-transfer.*{.*any;.*};' "$named_conf_path"; then
        echo "DNS Zone Transfer가 모든 사용자에게 허용되어 있습니다. 설정을 변경합니다."
        # allow-transfer 설정 변경 (예시: 특정 IP에만 허용. 실제 IP 주소로 교체 필요)
        sed -i '/allow-transfer.*{.*any;.*};/c\allow-transfer { 192.0.2.1; };' "$named_conf_path"
        echo "DNS Zone Transfer 설정이 업데이트 되었습니다. DNS 서비스를 재시작합니다."
        systemctl reload named
    else
        echo "DNS Zone Transfer가 허가된 사용자에게만 허용되어 있습니다."
    fi
else
    echo "U-34 DNS 서비스가 실행 중이지 않거나 /etc/named.conf 파일이 존재하지 않습니다."
fi
