#!/bin/bash

 

. function.sh

 
 

BAR

CODE [U-29] tftp, talk 서비스 비활성화

cat << EOF >> $result

[양호]: tftp, talk, ntalk 서비스가 비활성화 되어 있는 경우

[취약]: tftp, talk, ntalk 서비스가 활성화 되어 있는 경우

EOF

BAR


services="tftp talk ntalk"

for service in $services
do
    if systemctl is-enabled $service >/dev/null 2>&1; then
        WARN "$service 서비스가 사용하는 중입니다."
    else
        OK "$service 서비스가 사용하는 중입니다."
    fi
done


cat $result

echo ; echo
 
