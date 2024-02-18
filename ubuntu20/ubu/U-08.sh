#!/bin/bash

. function.sh

BAR 

CODE [U-08] /etc/shadow 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: /etc/shadow 파일의 소유자가 root이고, 권한이 400인 경우

[취약]: /etc/shadow 파일의 소유자가 root가 아니거나, 권한이 400이 아닌 경우

EOF

BAR

# 파일 소유자를 "root" 사용자와 "root" 그룹으로 변경
chown root:root /etc/shadow

# 파일의 권한을 600으로 설정
chmod 400 /etc/shadow

cat $result

echo ; echo
