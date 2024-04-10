#!/bin/bash

# Telnet 서비스 비활성화
# /etc/xinetd.d/telnet이 존재하는 경우, disable = yes로 설정
if [ -f /etc/xinetd.d/telnet ]; then
    sed -i 's/disable\s*=\s*no/disable = yes/g' /etc/xinetd.d/telnet
    echo "Telnet 서비스가 비활성화되었습니다."
fi

# /etc/inetd.conf에서 telnet 서비스 주석 처리
if grep -q "^telnet" /etc/inetd.conf; then
    sed -i '/^telnet/s/^/#/' /etc/inetd.conf
    echo "Telnet 서비스가 /etc/inetd.conf에서 비활성화되었습니다."
fi

# SSH 서비스에서 root 계정의 원격 접속 제한
# /etc/ssh/sshd_config 파일에서 PermitRootLogin을 no로 설정
if grep -Eq 'PermitRootLogin\s+(yes|without-password)' /etc/ssh/sshd_config; then
    sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
    echo "SSH 서비스에서 root 계정의 원격 접속이 제한되었습니다."
elif ! grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    echo "SSH 서비스 설정에 root 계정의 원격 접속 제한이 추가되었습니다."
fi

# sshd 서비스 재시작
service sshd restart || systemctl restart sshd
echo "sshd 서비스가 재시작되었습니다."

# 모든 조치 완료 메시지 출력
echo "모든 조치가 완료되었습니다. 시스템이 '양호' 상태로 설정되었습니다."