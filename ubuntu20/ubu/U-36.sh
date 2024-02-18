#!/bin/bash

. function.sh

BAR

CODE [U-36] 웹서비스 웹 프로세스 권한 제한

cat << EOF >> $result

[양호]: Apache 데몬이 root 권한으로 구동되지 않는 경우

[취약]: Apache 데몬이 root 권한으로 구동되는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# [Apache_home], [username] 및 [groupname]을(를) 적절한 값으로 바꿈
APACHE_CONF_FILE=/etc/apache2/apache2.conf
USERNAME=user
GROUPNAME=user

# 사용자 및 그룹 행을 새 값으로 바꿈
sed -i "s/User.*/User $USERNAME/g" $APACHE_CONF_FILE
sed -i "s/Group.*/Group $GROUPNAME/g" $APACHE_CONF_FILE

cat $result

echo ; echo