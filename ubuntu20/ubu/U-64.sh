#!/bin/bash

 

. function.sh
 

BAR

CODE [U-64] ftpusers 파일 설정

cat << EOF >> $result

[양호]: FTP 서비스가 비활성화 되어 있거나, 활성 시 root 계정 접속을 차단한 경우

[취약]: FTP 서비스가 활성화 되어 있고, root 계정 접속을 허용한 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1 


# ftp와 관련된 프로세스 목록을 가져옵니다
ftp_processes=$(ps -ef | grep ftp)

# ftp와 관련된 프로세스가 있는지 확인합니다
if [ -n "$ftp_processes" ]; then
  # ftp 서비스 이름 가져오기
  ftp_service=""
  if ls /etc/ftp* 1> /dev/null 2>&1; then
    ftp_service="ftp"
  elif ls /etc/vsftp* 1> /dev/null 2>&1; then
    ftp_service="vsftp"
  fi

 # ftp 서비스 중지
  if [ -n "$ftp_service" ]; then
    sudo service "$ftp_service" stop
    if [ $? -eq 0 ]; then
      OK "$ftp_service 서비스를 중지했습니다."
    else
      WARN "$ftp_service 서비스를 중지하지 못했습니다."
    fi
  else
    INFO "ftp 서비스를 확인할 수 없습니다."
  fi
else
  INFO "ftp 관련 프로세스를 찾을 수 없습니다."
fi 

# ftp 계정의 현재 로그인 셸을 가져옵니다
current_shell=$(grep "^ftp:" /etc/passwd | cut -d ':' -f 7)

# 현재 로그인 셸이 이미 /bin/false로 설정되어 있는지 확인하십시오
if [ "$current_shell" == "/bin/false" ]; then
  OK "ftp 계정이 이미 /bin/false를 로그인 셸로 가지고 있습니다."
else
  # ftp 계정의 로그인 셸을 /bin/false로 변경합니다
  sudo usermod -s /bin/false ftp
  
  # ftp 계정의 로그인 셸이 성공적으로 변경되었는지 확인합니다
  updated_shell=$(grep "^ftp:" /etc/passwd | cut -d ':' -f 7)
  if [ "$updated_shell" == "/bin/false" ]; then
    OK "ftp 계정 로그인 셸이 /bin/false로 성공적으로 변경되었습니다."
  else
    INFO "ftp 계정 로그인 셸을 /bin/false로 변경하지 못했습니다."
  fi
fi


cat $result

echo ; echo 


 
