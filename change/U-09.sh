#!/bin/bash

hosts_file='/etc/hosts'

# /etc/hosts 파일의 소유자를 root로 변경
chown root "$hosts_file"

# /etc/hosts 파일의 권한을 600으로 설정
chmod 600 "$hosts_file"

echo "/etc/hosts 파일의 소유자와 권한이 적절히 설정되었습니다."
