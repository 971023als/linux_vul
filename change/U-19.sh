#!/bin/bash

# Finger 서비스 비활성화 (xinetd를 통해 제공되는 경우)
if [ -f /etc/xinetd.d/finger ]; then
    echo "disabling" > /etc/xinetd.d/finger
    echo "Finger 서비스를 xinetd를 통해 비활성화합니다."
fi

# systemd를 사용하는 시스템에서 Finger 서비스 비활성화
if systemctl is-enabled finger.socket &> /dev/null; then
    systemctl stop finger.socket
    systemctl disable finger.socket
    echo "Finger 서비스를 systemd를 통해 비활성화하고, 실행 중인 소켓을 중지합니다."
fi

# Finger 프로세스 중지
pgrep -f finger &> /dev/null
if [ $? -eq 0 ]; then
    pkill -f finger
    echo "실행 중인 Finger 프로세스를 중지합니다."
fi

echo "U-19 Finger 서비스 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-19"
_change_item="disabling"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
