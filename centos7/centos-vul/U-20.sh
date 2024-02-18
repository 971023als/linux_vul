#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1  

 

 

BAR

CODE [U-20] Anonymous FTP 비활성화

cat << EOF >> $result

[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우

[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우

EOF

BAR

ftp_account="ftp"

if cat /etc/passwd | grep -q "$ftp_account"; then
  WARN "FTP 계정이 /etc/passwd 파일에 있습니다."
else
  OK "FTP 계정이 /etc/passwd 파일에 없습니다."
fi



cat $result

echo ; echo
