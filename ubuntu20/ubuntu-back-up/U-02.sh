#!/bin/bash 

. function.sh

 
BAR

CODE [U-02] 패스워드 복잡성 설정

cat << EOF >> $result

[양호]: 영문 숫자 특수문자가 혼합된 8 글자 이상의 패스워드가 설정된 경우.

[취약]: 영문 숫자 특수문자 혼합되지 않은 8 글자 미만의 패스워드가 설정된 경우.

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#  /etc/passwd  백업 파일 생성
INFO "백업 2번에서 진행하십시오."

cat $result

echo ; echo
