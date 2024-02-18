#!/bin/bash

. function.sh

BAR

CODE [U-20] Anonymous FTP 비활성화

cat << EOF >> $result

[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우

[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp /etc/vsftpd.conf.bak /etc/vsftpd.conf

cat $result

echo ; echo