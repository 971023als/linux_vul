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

HTTPD_CONF_FILE="/etc/apache2/apache2.conf"

sed -i "s/AllowOverride None/AllowOverride AuthConfig/g" "$HTTPD_CONF_FILE"

cat $result

echo ; echo