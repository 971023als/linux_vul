#!/bin/bash

. function.sh

BAR

CODE [U-35] 웹서비스 디렉토리 리스팅 제거

cat << EOF >> $result

[양호]: 디렉터리 검색 기능을 사용하지 않는 경우

[취약]: 디렉터리 검색 기능을 사용하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# Apache 구성 파일 정의
file="/etc/apache2/apache2.conf"

# "Options Indexes"을 "Options "로 바꿉니다
sed -i 's/Options Indexes/Options/g' $file

cat $result

echo ; echo