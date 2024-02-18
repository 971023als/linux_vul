#!/bin/bash

 

. function.sh


TMP1=`SCRIPTNAME`.log

>$TMP1    

BAR

CODE [U-18] 접속 IP 및 포트 제한 

cat << EOF >> $result

[양호]: /etc/hosts.deny 파일에 ALL Deny 설정후

/etc/hosts.allow 파일에 접근을 허용할 특정 호스트를 등록한 경우

[취약]: 위와 같이 설정되지 않은 경우

EOF

BAR

 
CHECK1=$(cat /etc/hosts.allow | grep -v "^#")
CHECK2=$(cat /etc/hosts.deny | grep -v "^#")

if [ -n "$CHECK1" ] && [ -n "$CHECK2" ] ; then
	OK "접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정한 경우"	
else
	WARN "접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정하지 않은 경우"
fi

 

cat $result

echo ; echo
