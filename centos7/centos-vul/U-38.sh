#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-38] Apache 불필요한 파일 제거 

cat << EOF >> $result

[양호]: 매뉴얼 파일 및 디렉터리가 제거되어 있는 경우

[취약]: 매뉴얼 파일 및 디렉터리가 제거되지 않은 경우

EOF

BAR


HTTPD_ROOT="/etc/httpd/conf/httpd.conf"
UNWANTED_ITEMS="manual samples docs"

if [ `ps -ef | grep httpd | grep -v "grep" | wc -l` -eq 0 ]; then
    INFO "아파치가 실행되지 않습니다."
else
    for item in $UNWANTED_ITEMS
    do
        if [ ! -d "$HTTPD_ROOT/$item" ] && [ ! -f "$HTTPD_ROOT/$item" ]; then
            OK "$item 을 $HTTPD_ROOT 에서 찾을 수 없습니다"
        else
            WARN "$item 을 $HTTPD_ROOT 에서 찾을 수 있습니다"
        fi
    done
fi

cat $result

echo ; echo