#!/bin/bash

passwd_file='/etc/passwd'

# /etc/passwd 파일의 소유자를 root로 변경
chown root "$passwd_file"

# /etc/passwd 파일의 권한을 644로 설정
chmod 644 "$passwd_file"

echo "/etc/passwd 파일의 소유자와 권한이 적절히 설정되었습니다."
