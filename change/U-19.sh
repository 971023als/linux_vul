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
