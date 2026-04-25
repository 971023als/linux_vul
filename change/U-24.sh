#!/bin/bash

# NFS 서비스 관련 데몬 목록
nfs_daemons=("nfsd" "rpcbind" "rpc.statd" "rpc.lockd")

echo "NFS 서비스 관련 데몬을 확인하고 비활성화합니다..."

# systemd를 사용하는 경우
for daemon in "${nfs_daemons[@]}"; do
    if systemctl is-active --quiet $daemon; then
        echo "$daemon 서비스가 활성화되어 있습니다. 비활성화를 시도합니다."
        systemctl stop $daemon
        systemctl disable $daemon
        echo "$daemon 서비스를 비활성화했습니다."
    else
        echo "$daemon 서비스는 이미 비활성화되어 있습니다."
    fi
done

# 서비스가 sysvinit를 사용하는 경우 (선택적)
# 예: service nfsd stop && chkconfig nfsd off

echo "U-24 NFS 서비스 관련 데몬 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-24"
_change_item="NFS 서비스 관련 데몬을 확인하고 비활성화합니다..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
