#!/bin/bash

# RPC 서비스 비활성화 함수
disable_rpc_service() {
    local service_name=$1
    local service_path="$2/$service_name"
    if [ -f "$service_path" ]; then
        sed -i 's/disable\s*=\s*no/disable = yes/' "$service_path"
        echo "$service_name 서비스가 $service_path 파일에서 비활성화되었습니다."
    fi
}

rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# /etc/xinetd.d 디렉터리 내의 RPC 서비스 비활성화
for service in "${rpc_services[@]}"; do
    disable_rpc_service "$service" "$xinetd_dir"
done

# /etc/inetd.conf 파일 내의 RPC 서비스 주석 처리
if [ -f "$inetd_conf" ]; then
    for service in "${rpc_services[@]}"; do
        if grep -q "$service" "$inetd_conf"; then
            sed -i "/$service/s/^/#/" "$inetd_conf"
            echo "$service 서비스가 $inetd_conf 파일에서 비활성화되었습니다."
        fi
    done
fi

echo "모든 불필요한 RPC 서비스가 비활성화되었습니다."
