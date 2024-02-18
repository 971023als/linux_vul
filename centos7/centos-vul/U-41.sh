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

# 확인할 Apache2 Document Root 디렉토리 설정
config_file="/etc/httpd/conf/httpd.conf"

# DocumentRoot가 기본 경로로 설정되어 있는지 확인합니다
if [ "$config_file" = "/var/www/html" ] ; then
  WARN "DocumentRoot가 기본 경로로 설정되었습니다: /var/www/html"
else
  OK "DocumentRoot가 기본 경로로 설정되지 않았습니다. "
fi

cat $result

echo ; echo
