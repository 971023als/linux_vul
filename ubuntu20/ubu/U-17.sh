#!/bin/bash

. function.sh

BAR

CODE [U-17] $HOME/.rhosts, hosts.equiv 사용 금지

cat << EOF >> $result

[양호]: login, shell, exec 서비스를 사용하지 않거나, 사용 시 아래와 같은 설정이 적용된 경우
       1. /etc/hosts.equiv 및 $HOME/.rhosts 파일 소유자가 root 또는, 해당 계정인 경우
       2. /etc/hosts.equiv 및 $HOME/.rhosts 파일 권한이 600 이하인 경우
       3. /etc/hosts.equiv 및 $HOME/.rhosts 파일 설정에 ‘+’ 설정이 없는 경우

[취약]: login, shell, exec 서비스를 사용하고, 위와 같은 설정이 적용되지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# /etc/hosts.equiv의 소유자를 루트로 변경합니다
chown root /etc/hosts.equiv

# /etc/hosts.equiv의 사용 권한을 600으로 변경합니다
chmod 600 /etc/hosts.equiv

# $HOME/.r 호스트의 소유자를 루트로 변경
chown root $HOME/.rhosts

# $HOME/.r 호스트의 사용 권한을 600으로 변경
chmod 600 $HOME/.rhosts

# /etc/hosts.equiv에서 '+' 제거
sed -i '/^+/d' /etc/hosts.equiv

# $HOME/.r 호스트에서 '+' 제거
sed -i '/^+/d' $HOME/.rhosts

cat $result

echo ; echo