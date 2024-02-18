#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-41] Apache 웹 서비스 영역의 분리 

cat << EOF >> $result

[양호]: DocumentRoot를 별도의 디렉터리로 지정한 경우

[취약]: DocumentRoot를 기본 디렉터리로 지정한 경우

EOF

BAR

#  백업 파일 생성
INFO "35번에서 /etc/httpd/conf/httpd.conf 백업 파일이 생성되었습니다."

cat $result

echo ; echo
