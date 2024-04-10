#!/bin/bash

# NFS 서비스 비활성화 함수
disable_nfs_service() {
    local service_name=$1
    if systemctl is-enabled --quiet $service_name; then
        systemctl stop $service_name
        systemctl disable $service_name
        echo "$service_name 서비스가 비활성화되었습니다."
    else
        echo "$service_name 서비스는 이미 비활성화 상태입니다."
    fi
}

# NFS 및 관련 서비스 목록
nfs_services=("nfs-server" "nfs-lock" "rpcbind" "rpc-statd" "nfs-idmapd")

# 각 서비스에 대해 비활성화 시도
for service in "${nfs_services[@]}"; do
    disable_nfs_service $service
done

echo "모든 NFS 관련 서비스가 비활성화되었습니다."
