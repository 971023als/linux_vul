#!/bin/bash

. function.sh

BAR

CODE [U-22] crond 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하인 경우

[취약]: crontab 명령어 일반사용자 사용가능하거나, crond 관련 파일 640 이상인 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/crontab.bak /etc/crontab
cp /etc/cron.hourly.bak /etc/cron.hourly
cp /etc/cron.daily.bak /etc/cron.daily
cp /etc/cron.weekly.bak /etc/cron.weekly
cp /etc/cron.monthly.bak /etc/cron.monthly
cp /etc/cron.allow.bak /etc/cron.allow
cp /etc/cron.deny.bak /etc/cron.deny
cp /var/spool/cron/*.bak /var/spool/cron/*

cat $result

echo ; echo