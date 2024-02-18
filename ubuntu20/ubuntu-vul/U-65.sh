#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-65] at 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: at 접근제어 파일의 소유자가 root이고, 권한이 640 이하인 경우

[취약]: at 접근제어 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 


# at 명령을 사용할 수 있는지 확인하십시오
if command -v at >/dev/null; then
    INFO "at 명령을 사용할 수 있습니다."
else
    OK "at 명령을 사용할 수 없습니다."
fi

# at 관련 파일의 사용 권한을 확인하십시오
at_dir="/etc/at.allow"
if [ -f $at_dir ]; then
    permission=$(stat -c %a $at_dir)
    if [ $permission -ge 640 ]; then
        WARN "관련 파일의 권한이 640 이상입니다."
    else
        OK "관련 파일의 권한이 640 미만입니다."
    fi
else
    OK "관련 파일이 존재하지 않습니다"
fi

cat $result

echo ; echo 