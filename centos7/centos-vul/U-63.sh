#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-63] ftpusers 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우

[취약]: ftpusers 파일의 소유자가 root아니거나, 권한이 640 이하가 아닌 경우

EOF

BAR

ftpusers_file="/etc/vsftpd/ftpusers"

owner=$(stat -c '%U' $ftpusers_file)

# ftpusers 파일 확인
if [ ! -f $ftpusers_file ]; then
  INFO "ftpusers 파일이 없습니다. 확인해주세요."
else
  # ftpusers 파일 소유자 root 확인
  if [[ $owner == "root" ]]; then
      OK "root가 users 파일을 소유하고 있습니다."
  else
      WARN "root가 users 파일을 소유하고 있지 않습니다."
  fi
  # ftp 사용자에 대한 권한

  if [[ `stat -c '%a' $ftpusers_file` -lt 640 ]]; then
    WARN "권한이 640 초과입니다"
  else
      # 스크립트가 이 지점에 도달하면 소유권 및 사용 권한이 올바른 것입니다
      OK "권한이 600 이하입니다."
  fi
fi



cat $result

echo ; echo 

 
