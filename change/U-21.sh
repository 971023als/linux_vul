#!/bin/bash

# xinetd 또는 inetd를 통해 제공되는 r 계열 서비스 비활성화
r_services=("rsh" "rlogin" "rexec" "shell" "login" "exec")

# /etc/xinetd.d 디렉터리 내의 r 계열 서비스 파일 수정
for service in "${r_services[@]}"; do
    service_path="/etc/xinetd.d/$service"
    if [ -f "$service_path" ]; then
        sed -i 's/disable[ ]*=[ ]*no/disable = yes/g' "$service_path"
        echo "$service 서비스가 xinetd를 통해 비활성화되었습니다."
    fi
done

# /etc/inetd.conf 파일 내의 r 계열 서비스 비활성화
if [ -f "/etc/inetd.conf" ]; then
    for service in "${r_services[@]}"; do
        sed -i "/$service/s/^/#/" "/etc/inetd.conf"
    done
    echo "/etc/inetd.conf 파일 내의 r 계열 서비스가 비활성화되었습니다."
fi

# 서비스 재시작
if systemctl is-active xinetd &> /dev/null; then
    systemctl restart xinetd
    echo "xinetd 서비스를 재시작했습니다."
fi

if systemctl is-active inetd &> /dev/null; then
    systemctl restart inetd
    echo "inetd 서비스를 재시작했습니다."
fi

echo "U-21 r 계열 서비스 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-21"
_change_item="$service 서비스가 xinetd를 통해 비활성화되"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
