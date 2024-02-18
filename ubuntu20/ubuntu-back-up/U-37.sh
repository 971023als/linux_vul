#!/bin/bash

. function.sh

BAR

CODE [U-37] 웹서비스 상위 디렉토리 접근 금지

cat << EOF >> $result

[양호]: 상위 디렉터리에 이동제한을 설정한 경우

[취약]: 상위 디렉터리에 이동제한을 설정하지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
INFO "35번에서 /etc/apache2/apache2.conf 백업 파일이 생성되었습니다."


cat $result

echo ; echo