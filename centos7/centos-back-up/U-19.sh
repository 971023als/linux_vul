#!/bin/bash

. function.sh

BAR

CODE [U-19] finger 서비스 비활성화		

cat << EOF >> $result

[양호]: Finger 서비스가 비활성화 되어 있는 경우

[취약]: Finger 서비스가 활성화 되어 있는 경우

EOF

BAR

# finger 파일 설정
echo "service finger
{
socket_type = stream
wait = no
user = nobody
server = /usr/sbin/in.fingerd
disable = yes
}" > /etc/xinetd.d/finger

cat $result

echo ; echo
