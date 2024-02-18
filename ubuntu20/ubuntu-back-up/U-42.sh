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

# 로그 파일 경로 설정
log_file="/var/log/patch.log"

# 백업 파일 경로 설정
backup_file="/var/log/patch.log.backup"

# 백업 파일 경로 설정
cp $log_file $backup_file

cat $result

echo ; echo 

 
