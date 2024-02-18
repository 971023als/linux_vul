#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1 
 
BAR

CODE [U-62] ftp 계정 shell 제한

cat << EOF >> $result

[양호]: ftp 계정에 /bin/false 쉘이 부여되어 있는 경우

[취약]: ftp 계정에 /bin/false 쉘이 부여되지 않는 경우

EOF

BAR

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

 
