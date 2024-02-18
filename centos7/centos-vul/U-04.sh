#!/bin/bash

 

 

. function.sh

 
 TMP1=`SCRIPTNAME`.log

> $TMP1

BAR

CODE [U-04] 패스워드 파일 보호

cat << EOF >> $result

[양호]: 쉐도우 패스워드를 사용하거나, 패스워드를 암호화하여 저장하는 경우

[취약]: 쉐도우 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않는 경우

EOF

BAR


FILENAME1=/etc/shadow
FILENAME2=/etc/passwd


if [ -f $FILENAME ] ; then
	OK "쉐도우 파일이 존재합니다."
	CHECK=$(cat $FILENAME2 | awk -F: '{print $2}' | grep -v 'x')
	if [ -z $CHECK ] ; then
		OK "쉐도우 패스워드를 사용하거나, 패스워드를 암호화하여 저장하는 경우"
	else
		WARN "쉐도우 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않는 경우"
	fi
else
	INFO "쉐도우 파일이 존재하지 않습니다."
fi



 

cat $result

echo ; echo
