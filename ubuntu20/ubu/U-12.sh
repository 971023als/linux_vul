#!/bin/bash

. function.sh

BAR

CODE [U-12] /etc/services 파일 소유자 및 권한 설정		

cat << EOF >> $result
[양호]: etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하
인 경우
[취약]: etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하
인 경우
EOF

BAR

# 파일 소유자를 "root" 사용자와 "root" 그룹으로 변경
chown root:root /etc/services

# 파일의 권한을 644로 설정
chmod 644 /etc/services


cat $result

echo ; echo
