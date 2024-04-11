#!/bin/bash

# /etc/hosts.deny에 모든 접속을 기본적으로 거부하는 규칙 설정
echo "ALL: ALL" > /etc/hosts.deny
echo "/etc/hosts.deny 파일에 모든 접속을 거부하는 규칙을 설정했습니다."

# /etc/hosts.allow 파일에서 허용할 특정 호스트 설정 예시
# 여기서는 실제로 특정 IP를 허용하는 규칙을 추가하지 않습니다.
# 실제 환경에서는 아래의 예시처럼 필요한 규칙을 추가해야 합니다.
# 예: echo "sshd: 192.168.0.1" >> /etc/hosts.allow
# 이 스크립트는 예시를 제공하기 위한 것이므로, 실제 환경에 맞게 수정해 사용해야 합니다.

# 기존 /etc/hosts.allow 파일 백업
if [ -f "/etc/hosts.allow" ]; then
    cp /etc/hosts.allow /etc/hosts.allow.backup
    echo "/etc/hosts.allow 파일의 백업본을 생성했습니다."
fi

# /etc/hosts.allow 파일 초기화 (선택적 조치)
> /etc/hosts.allow
echo "/etc/hosts.allow 파일을 초기화했습니다. 필요한 접속 허용 규칙을 추가해주세요."

echo "U-18 접속 IP 및 포트 제한 설정 조치가 완료되었습니다."
