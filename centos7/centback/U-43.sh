#!/bin/bash

. function.sh

BAR

CODE [U-43] 로그의 정기적 검토 및 보고

cat << EOF >> $result

[양호]: 접속기록 등의 보안 로그, 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우

[취약]: 위 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어 지지 않는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# Get the latest backup of the sulog file
sulog_backup=$(ls -t /var/log/sulog_* | head -n 1)

#    백업 파일 생성
cp $sulog_backup /var/log/sulog

# Get the latest backup of the auth.log file
auth_backup=$(ls -t /var/log/auth_* | head -n 1)

#    백업 파일 생성
cp $auth_backup /var/log/auth.log

# Get the latest backup of the auth_logs file
auth_logs_backup=$(ls -t /var/log/auth_logs_* | head -n 1)

#    백업 파일 생성
cp $auth_logs_backup /var/log/auth_logs

cat $result

echo ; echo