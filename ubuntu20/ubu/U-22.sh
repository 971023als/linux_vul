#!/bin/bash

. function.sh

BAR

CODE [U-22] crond 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하인 경우

[취약]: crontab 명령어 일반사용자 사용가능하거나, crond 관련 파일 640 이상인 경우

EOF

BAR

chown root:root /etc/crontab
chmod 640 /etc/crontab

chown root:root /etc/cron.hourly 
chmod 640 /etc/cron.hourly 

chown root:root /etc/cron.daily 
chmod 640 /etc/cron.daily 

chown root:root /etc/cron.weekly
chmod 640 /etc/cron.weekly

chown root:root /etc/cron.monthly
chmod 640 /etc/cron.monthly

chown root:root /etc/cron.allow 
chmod 640 /etc/cron.allow 

chown root:root /etc/cron.deny 
chmod 640 /etc/cron.deny 

chown root:root /var/spool/cron*
chmod 640 /var/spool/cron*

chown root:root /var/spool/cron/crontabs/
chmod 640 /var/spool/cron/crontabs/

cat $result

echo ; echo