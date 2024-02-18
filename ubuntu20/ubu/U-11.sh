#!/bin/bash

. function.sh

BAR

CODE [U-11] /etc/rsyslog.conf 파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: /etc/rsyslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이
하인 경우

[취약]: /etc/rsyslog.conf 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 
640 이하가 아닌 경우

EOF

BAR

# 파일 소유자를 "root" 사용자와 "root" 그룹으로 변경
chown root:root /etc/rsyslog.conf

# 파일의 권한을 644로 설정
chmod 640 /etc/rsyslog.conf

cat $result

echo ; echo
