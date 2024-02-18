#!/bin/bash

. function.sh 
   
BAR

CODE [U-42] 최신 보안패치 및 벤더 권고사항 적용

cat << EOF >> $result

[양호]: 패치 적용 정책을 수립하여 주기적으로 패치를 관리하고 있는 경우

[취약]: 패치 적용 정책을 수립하지 않고 주기적으로 패치관리를 하지 않는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  


INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

INFO "이 부분은 복구와 관련된 항목이 아닙니다"

cat $result

echo ; echo 

 
