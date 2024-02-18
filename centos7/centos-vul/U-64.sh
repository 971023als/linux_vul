#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-64] ftpusers 파일 설정

cat << EOF >> $result

[양호]: FTP 서비스가 비활성화 되어 있거나, 활성 시 root 계정 접속을 차단한 경우

[취약]: FTP 서비스가 활성화 되어 있고, root 계정 접속을 허용한 경우

EOF

BAR

# ftp 프로세스가 실행 중인지 확인합니다
ftp_process=`ps -ef | grep ftp`
if [ ! -f "$ftp_process" ]; then
  INFO "ftp 서비스를 확인할 수 없습니다."
else  
  if [ -z "$ftp_process" ]; then
    OK "프로세스가 실행되고 있지 않습니다."
  else
    WARN "프로세스가 실행되고 있습니다."
  fi
fi

# /etc/ftp* 또는 /etc/vsftp* 파일이 있는지 확인하십시오
ftp_files=`ls -al /etc/ftp*`
vsftp_files=`ls -al /etc/vsftp*`
 
if [ -z "$ftp_files" ] && [ -z "$vsftp_files" ]; then
    OK "/etc/vsftp* 및 /etc/vsftp* 파일이 존재하지 않습니다"
else
    WARN "/etc/vsftp* 및 /etc/vsftp* 파일이 존재합니다"
fi

# ftp 계정의 셸에 /bin/false가 있는지 확인합니다
ftp_user=`grep ftp /etc/passwd`
if [ -z "$ftp_user" ]; then
  OK "/etc/passwd에서 사용자를 찾을 수 없음"
else
  WARN "/etc/passwd에서 사용자를 찾을 수 있음"
fi


cat $result

echo ; echo 


 
