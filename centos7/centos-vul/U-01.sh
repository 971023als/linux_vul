#!/bin/bash

. function.sh


TMP1=$(SCRIPTNAME).log

> $TMP1

BAR

CODE [U-01] root 계정 원격 접속 제한

cat << EOF >> $result

[양호]: 원격 서비스를 사용하지 않거나 사용시 직접 접속을 차단한 경우

[취약]: root 직접 접속을 허용하고 원격 서비스를 사용하는 경우

EOF

BAR


# Check if the PermitRootLogin option is set to yes in the SSH configuration file
if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    WARN "원격 터미널 서비스를 통해 루트 직접 액세스가 허용됨"
else
    OK "원격 터미널 서비스를 통해 루트 직접 액세스가 허용되지 않음"
fi


cat $result

echo ; echo
