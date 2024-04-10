#!/bin/bash

# /etc/exports 파일이 존재하는지 확인
if [ ! -f "/etc/exports" ]; then
    echo "/etc/exports 파일이 존재하지 않습니다. NFS 설정을 진행할 수 없습니다."
    exit 1
fi

# /etc/exports 파일에서 '*' 사용을 제거하고, 보안 옵션 설정
# 예시로, 모든 공유에 대해 everyone 접근을 제거하고 root_squash 옵션을 적용합니다.
# 실제 환경에 맞게 수정이 필요할 수 있습니다.
sed -i '/\*/d' /etc/exports
sed -i '/^\/.*$/ s/$/ root_squash/' /etc/exports

# NFS 서비스 재시작 (시스템에 따라 다를 수 있음)
systemctl restart nfs-server

echo "/etc/exports 파일이 수정되었습니다. 불필요한 everyone 공유가 제한되고, 보안 옵션이 적용되었습니다."
echo "NFS 서비스가 재시작되었습니다."
