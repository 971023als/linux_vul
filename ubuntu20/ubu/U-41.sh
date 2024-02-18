#!/bin/bash

. function.sh

BAR

CODE [U-41] 웹서비스 영역의 분리

cat << EOF >> $result

[양호]: DocumentRoot를 별도의 디렉터리로 지정한 경우

[취약]: DocumentRoot를 기본 디렉터리로 지정한 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# 확인할 Apache2 Document Root 디렉토리 설정
config_file="/etc/apache2/sites-available/000-default.conf"

# DocumentRoot가 기본 경로로 설정되어 있는지 확인합니다
if [ "$config_file" = "/var/www/html" ] ; then
  INFO "DocumentRoot가 기본 경로로 설정되었습니다: /var/www/html"
else
  sed -i 's|DocumentRoot.*|DocumentRoot "/home/ubuntu/newphp/"|' /etc/apache2/sites-available/000-default.conf
  INFO "DocumentRoot를 /home/ubuntu/newphp/로 변경되었습니다."
fi

cat $result

echo ; echo