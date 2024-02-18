#!/bin/bash

. function.sh

BAR

CODE [U-72] 정책에 따른 시스템 로깅 설정

cat << EOF >> $result

[양호]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있는 경우

[취약]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 

#  백업 파일 생성
cp /var/log/secure.bak /var/log/secure

#  백업 파일 생성
cp /var/log/message.bak /var/log/message

#  백업 파일 생성
cp /var/log/audit/audit.log.bak /var/log/audit/audit.log

#  백업 파일 생성
cp /var/log/httpd/access_log.bak /var/log/httpd/access_log

#  백업 파일 생성
cp /var/log/httpd/error_log.bak /var/log/httpd/error_log

#  백업 파일 생성
cp /etc/rsyslog.conf.bak /etc/rsyslog.conf

#  백업 파일 생성
cp /etc/httpd/conf/httpd.conf.bak /etc/httpd/conf/httpd.conf

#  백업 파일 생성
cp /etc/audit/auditd.conf.bak /etc/audit/auditd.conf

cat $result

echo ; echo 

 
