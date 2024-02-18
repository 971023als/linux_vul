#!/bin/bash

. function.sh

BAR

CODE [U-34] DNS Zone Transfer 설정

cat << EOF >> $result

[양호]: DNS 서비스 미사용 또는, Zone Transfer를 허가된 사용자에게만 허용한 경우

[취약]: DNS 서비스를 사용하며 Zone Transfer를 모든 사용자에게 허용한 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  서비스 관련 파일
INFO "서비스 관련 파일이라 조치 34번 진행하시면 됩니다."


cat $result

echo ; echo