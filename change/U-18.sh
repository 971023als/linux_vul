#!/bin/bash

# 사용자로부터 IP 주소와 포트 번호 입력 받기
read -p "허용할 IP 주소를 입력하세요: " ip_address
read -p "허용할 포트 번호를 입력하세요: " port_number

# /etc/hosts.allow 파일 경로
hosts_allow_path="/etc/hosts.allow"

# /etc/hosts.allow 파일에 접속 허용 설정 추가
echo "sshd: $ip_address:$port_number" >> "$hosts_allow_path"

echo "$hosts_allow_path 파일에 $ip_address 주소에서 포트 $port_number 로의 접속을 허용하는 설정을 추가했습니다."

echo "접속 IP 및 포트 제한 설정이 완료되었습니다."
