#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1   

 

BAR

CODE [U-61] ftp 서비스 확인

cat << EOF >> $result

[양호]: FTP 서비스가 비활성화 되어 있는 경우

[취약]: FTP 서비스가 활성화 되어 있는 경우

EOF

BAR

yum install net-tools -y

yum install -y iproute2

# FTP 서비스의 상태를 확인합니다
ftp_status=$(service ftp status 2>&1)

# /etc/passwd에서 FTP 계정을 확인합니다
ftp_entry=$(grep "^ftp:" /etc/passwd)

# FTP 계정의 셸을 확인합니다
ftp_shell=$(grep "^ftp:" /etc/passwd | awk -F: '{print $7}')

# FTP 포트가 수신 중인지 확인합니다
if netstat -tnlp | grep -q ':21'; then
  if [ "$ftp_shell" == "/bin/false" ]; then
    OK "FTP 계정의 셸이 /bin/false로 설정되었습니다."
  else
    WARN "FTP 계정의 셸을 /bin/false로 설정할 수 없습니다."
  fi
else
  OK "FTP 포트(21)가 열려 있지 않습니다."
fi

cat $result

echo ; echo 
