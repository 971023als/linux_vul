#!/bin/bash

# NIS 관련 서비스 비활성화
nis_services=("ypserv" "ypbind" "yppasswdd" "ypxfrd" "rpc.yppasswdd" "rpc.ypupdated")

echo "NIS 서비스를 확인하고 있습니다..."

for service in "${nis_services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "$service 서비스가 활성화되어 있습니다. 비활성화를 시도합니다."
        systemctl stop $service
        systemctl disable $service
        echo "$service 서비스를 비활성화하고 중지했습니다."
    else
        echo "$service 서비스는 이미 비활성화되어 있습니다."
    fi
done

echo "U-28 NIS 서비스 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-28"
_change_item="NIS 서비스를 확인하고 있습니다..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
