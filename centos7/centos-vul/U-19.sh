#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1  

BAR

CODE [U-19] finger 서비스 비활성화

cat << EOF >> $result  

[양호]: Finger 서비스가 비활성화 되어 있는 경우

[취약]: Finger 서비스가 활성화 되어 있는 경우

EOF

BAR


# Check if the finger daemon is running
if pgrep -x "fingerd" > /dev/null; then
    WARN "Finger 서비스가 실행되고 있습니다"
else
    OK "Finger 서비스가 실행되고 있지 않습니다"
fi



 

cat $result

echo ; echo
