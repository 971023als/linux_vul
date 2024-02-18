#!/bin/bash

. function.sh
 
BAR

CODE [U-63] ftpusers 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우

[취약]: ftpusers 파일의 소유자가 root아니거나, 권한이 640 이하가 아닌 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 

# 파일의 소유자를 루트로 변경
chown root:root /etc/vsftpd/ftpusers

# 파일 권한을 640으로 변경
chmod 640 /etc/vsftpd/ftpusers

cat $result

echo ; echo 

 
