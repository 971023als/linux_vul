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


INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

# Start DNS service
service named start


cat $result

echo ; echo