#!/bin/bash

. function.sh

BAR

CODE [U-28] NIS , NIS+ 점검		

cat << EOF >> $result

[양호]: NIS 서비스가 비활성화 되어 있거나, 필요 시 NIS+를 사용하는 경우

[취약]: NIS 서비스가 활성화 되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  서비스 관련 파일
INFO "서비스 관련 파일이라 조치 28번 진행하시면 됩니다."

cat $result

echo ; echo
