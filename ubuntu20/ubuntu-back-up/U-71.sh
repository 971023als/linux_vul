#!/bin/bash


. function.sh
 
BAR

CODE [U-71] Apache 웹서비스 정보 숨김

cat << EOF >> $result

[양호]: ServerTokens Prod, ServerSignature Off로 설정되어있는 경우

[취약]: ServerTokens Prod, ServerSignature Off로 설정되어있지 않은 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1 

#    백업 파일 생성
INFO "35번에서 /etc/apache2/apache2.conf 백업 파일이 생성되었습니다."

cat $result

echo ; echo 