#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1

BAR

CODE [U-07] /etc/passwd 파일 소유자 및 권한 설정

cat << EOF >> $result

[ 양호 ] : /etc/passwd 파일의 소유자가 root이고, 권한이 644 이하인 경우

[ 취약 ] : /etc/passwd 파일의 소유자가 root가 아니거나, 권한이 644 이하가 아닌 경우

EOF

BAR


# check if the file is owned by root
if [ $(stat -c "%U" /etc/passwd) != "root" ]; then
    WARN "/etc/passwd 파일이 루트에 의해 소유되지 않습니다."
else
    OK "/etc/passwd 파일이 루트에 의해 소유됩니다."
fi

# check if the file permissions are less than 644
if [ $(stat -c "%a" /etc/passwd) -lt 644 ]; then
    WARN "/etc/passwd 파일에 644 미만의 권한이 있습니다."
else
    OK "/etc/passwd 파일에 644 이상의 권한이 있습니다."
fi


cat $result

echo ; echo
