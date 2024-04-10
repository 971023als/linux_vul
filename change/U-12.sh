#!/bin/bash

services_file='/etc/services'

# /etc/services 파일의 소유자를 root로 변경
chown root "$services_file"

# /etc/services 파일의 권한을 644로 설정
chmod 644 "$services_file"

echo "/etc/services 파일의 소유자와 권한이 적절히 설정되었습니다."
