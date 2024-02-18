#!/bin/bash

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-37] Apache 상위 디렉터리 접근 금지 

cat << EOF >> $result

[양호]: 상위 디렉터리에 이동제한을 설정한 경우

[취약]: 상위 디렉터리에 이동제한을 설정하지 않은 경우

EOF

BAR

HTTPD_CONF_FILE="/etc/httpd/conf/httpd.conf"
ALLOW_OVERRIDE_OPTION="AllowOverride AuthConfig"

if [ ! -f "$HTTPD_CONF_FILE" ]; then
    INFO "$HTTPD_CONF_FILE 을 찾을 수 없습니다."
else
    if grep -q "$ALLOW_OVERRIDE_OPTION" "$HTTPD_CONF_FILE"; then
        OK "$HTTPD_CONF_FILE 에서 $ALLOW_OVERRIDE_OPTION 을 찾았습니다."
    else
        WARN "$HTTPD_CONF_FILE 에서 $ALLOW_OVERRIDE_OPTION 을 찾을 수 없습니다."
    fi
fi



cat $result

echo ; echo

 

 

