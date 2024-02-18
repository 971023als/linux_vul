#!/bin/bash

 

. function.sh

 

TMP1=`SCRIPTNAME`.log

>$TMP1

 

 

BAR 

CODE [U-08] /etc/shadow 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: /etc/shadow 파일의 소유자가 root이고, 권한이 400인 경우

[취약]: /etc/shadow 파일의 소유자가 root가 아니거나, 권한이 400이 아닌 경우

EOF

BAR



# 파일이 루트에 의해 소유되는지 확인합니다
if [ $(stat -c "%U" /etc/shadow) != "root" ]; then
    WARN "/etc/shadow 파일이 루트에 의해 소유되지 않습니다."
else
    OK "/etc/shadow 파일이 루트에 의해 소유됩니다."
fi

# 파일 사용 권한이 400보다 작은지 확인합니다
if [ $(stat -c "%a" /etc/shadow) -lt 400 ]; then
    WARN "/etc/shadow 파일에 400 미만의 권한이 있습니다."
else
    OK "/etc/shadow 파일에 400 이상의 권한이 있습니다."
fi


cat $result

echo ; echo
