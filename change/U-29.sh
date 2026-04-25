#!/bin/bash

# tftp, talk, ntalk 서비스 비활성화
services=("tftp" "talk" "ntalk")

echo "tftp, talk, ntalk 서비스를 확인하고 있습니다..."

# /etc/xinetd.d 디렉터리 내의 서비스 파일 수정
for service in "${services[@]}"; do
    if [ -f "/etc/xinetd.d/$service" ]; then
        echo "$service 서비스를 비활성화합니다."
        sed -i '/disable[ ]*=[ ]*no/c\disable         = yes' "/etc/xinetd.d/$service"
    fi
done

# /etc/inetd.conf 파일 내의 서비스 주석 처리
if [ -f "/etc/inetd.conf" ]; then
    for service in "${services[@]}"; do
        if grep -q "^$service" "/etc/inetd.conf"; then
            echo "$service 서비스를 /etc/inetd.conf에서 주석 처리합니다."
            sed -i "/^$service/s/^/#/" "/etc/inetd.conf"
        fi
    done
fi

echo "U-29 tftp, talk, ntalk 서비스 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-29"
_change_item="tftp, talk, ntalk 서비스를 확인하고 있습"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
