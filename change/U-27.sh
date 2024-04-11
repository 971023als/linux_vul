#!/bin/bash

# RPC 서비스 목록
rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")

# /etc/xinetd.d 및 /etc/inetd.conf 내 RPC 서비스 비활성화
echo "RPC 서비스를 검사하고 있습니다..."

for service in "${rpc_services[@]}"; do
    # xinetd를 통해 관리되는 경우
    if [ -f "/etc/xinetd.d/$service" ]; then
        echo "$service 서비스를 비활성화합니다."
        sed -i 's/disable[ ]*=[ ]*no/disable = yes/' "/etc/xinetd.d/$service"
    fi

    # inetd를 통해 관리되는 경우
    if grep -q "$service" /etc/inetd.conf 2>/dev/null; then
        echo "$service 서비스를 /etc/inetd.conf에서 주석 처리합니다."
        sed -i "/$service/s/^/#/" /etc/inetd.conf
    fi
done

# rpcbind 서비스 비활성화 (systemd를 사용하는 경우)
if systemctl is-active --quiet rpcbind; then
    systemctl stop rpcbind
    systemctl disable rpcbind
    echo "rpcbind 서비스를 비활성화하고 중지했습니다."
fi

echo "U-27 RPC 서비스 비활성화 작업이 완료되었습니다."
