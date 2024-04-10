#!/bin/bash

shadow_file='/etc/shadow'

# /etc/shadow 파일의 소유자를 root로 변경
chown root "$shadow_file"

# /etc/shadow 파일의 권한을 400으로 설정
chmod 400 "$shadow_file"

echo "/etc/shadow 파일의 소유자와 권한이 적절히 설정되었습니다."
