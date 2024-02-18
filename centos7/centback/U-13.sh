#!/bin/bash

. function.sh

BAR

CODE [U-13] SUID, SGID, Sticky bit 설정 및 권한 설정		

cat << EOF >> $result

[양호]: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 
경우

[취약]: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/passwd  백업 파일 생성
INFO "4번에서 /etc/passwd 백업 파일이 생성되었습니다."

cat $result

echo ; echo
