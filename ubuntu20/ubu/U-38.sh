#!/bin/bash

. function.sh

BAR

CODE [U-38] 웹서비스 불필요한 파일 제거

cat << EOF >> $result

[양호]: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있는 경우

[취약]: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되지 않은 경우 

EOF

BAR
 
HTTPD_ROOT="/etc/apache2/apache2.conf"
UNWANTED_ITEMS="manual samples docs"

if [ `ps -ef | grep httpd | grep -v "grep" | wc -l` -eq 0 ]; then
    INFO "아파치가 실행되지 않습니다."
else
    for item in $UNWANTED_ITEMS
    do
        if [ -d "$HTTPD_ROOT/$item" ] || [ -f "$HTTPD_ROOT/$item" ]; then
            rm -rf "$HTTPD_ROOT/$item"
            INFO "$item 이 $HTTPD_ROOT 에서 제거되었습니다."
        fi
    done
fi

cat $result

echo ; echo